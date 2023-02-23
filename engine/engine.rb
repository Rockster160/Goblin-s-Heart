require_relative "input"
require_relative "draw"
require_relative "colorize"
require "pry-rails"

class Engine
  extend Draw
  include Draw
  attr_accessor :tick_time, :last_key, :t
  # [
  #   ENV["LINES"].to_i.nonzero? || 25,
  #   ENV["COLUMNS"].to_i.nonzero? || 80,
  # ]

  def initialize(opts={})
    @t = 0
    @last_key = nil
    @tick_callback = opts[:tick]
    @input_callback = opts[:input]
    @instant_input_callback = opts[:instant_input]
    @draw_callback = opts[:draw]
    @loop_callback = opts[:loop]
    @start_callback = opts[:start]
    @input_opts = opts[:input_opts] || {}
    @tick_time = opts.key?(:tick_time) ? opts[:tick_time] : 0.15
    @tick_time = 0.001 if @tick_time.to_f < 0.001
    opts[:game].engine = self if opts[:game]&.respond_to?(:engine)
  end

  def self.start(callbacks)
    $engine = new(callbacks)
    $engine.go
  end

  def self.method_missing(method, *args, &block)
    $engine.send(method)
  end

  def goal_fps
    1/@tick_time.to_f
  end
  def fps=(new_fps)
    @tick_time = (1/new_fps.to_f).clamp(0.001, 10)
  end

  def self.prepause
    $running = false
    $inputthread = 0
    $pry = false
    Input.mode(:term)
    print Colorize.reset_code
  end

  def self.postpause
    $running = true
    $inputthread = Input.inputthread($engine)
    Input.mode(:game)
  end

  def self.pause(ctx=binding)
    # Engine.pause(binding)
    l = Proc.new { |var| ctx.eval(var.to_s) }
    # l[:cell] => calls local var `cell` from previous binding
    prepause
    $done || ($done ||= true) && binding.pry
    postpause
  end

  def self.benchmark(&block)
    t = Time.now.to_f
    response = block.call
    drawat([0, 25], "#{Time.now.to_f - t}#{newline}")
    response
  end

  def go
    start

    if @loop_callback
      @loop_callback&.call
    else
      loop { tick }
    end
  rescue StandardError => e
    quit
    puts "#{e.inspect}"
    puts e.backtrace
  ensure
    fullquit
  end

  def last_key=(new_key)
    fullquit if new_key == :control_c
    @last_key = new_key
    @instant_input_callback&.call(@last_key)
  end

  def tick
    return unless $running
    # call once every FPS
    @t += 1
    Input.keys_down.uniq.each do |key|
      @input_callback&.call(key) if key
    end
    @last_key = nil
    Input.release_keys
    @tick_callback&.call
    @draw_callback&.call
    sleep @tick_time if @tick_time && @tick_time > 0
  end

  def start
    system "clear" or system "cls"

    Input.mode(:game, **@input_opts)
    $running = true
    $inputthread = Input.inputthread(self)
    @start_callback&.call
  end

  def quit
    print Colorize.reset_code
    $running = false
    $inputthread = 0  # Kill the input thread
    Input.mode(:term)
    true # success
  end

  def fullquit
    quit
    exit
  end
end
