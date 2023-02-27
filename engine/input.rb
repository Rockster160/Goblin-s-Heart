require "io/console"
require "io/wait"

$mousecoord = []
module Input
  module_function
  @@keys_down = []

  def keys_down
    @@keys_down
  end

  def release_keys
    @@keys_down = []
  end

  def show_cursor
    print "\e[?25h"
  end

  def hide_cursor
    print "\e[?25l"
  end

  # https://stackoverflow.com/a/55437976/3981789
  def listen_mouse_events
    print "\e[?1000;1003;1006;1015h"
  end

  def ignore_mouse_events
    print "\e[?1000;1003;1006;1015l"
  end

  def mode=(term_mode)
    mode(term_mode)
  end

  def mode(term_mode, cursor: false, mouse: false)
    term_mode = term_mode == :game ? false : term_mode
    $prestate ||= `stty -g` # Get initial state
    if term_mode
      ignore_mouse_events
      show_cursor
      `stty #{$prestate}` # Reset initial state
    else
      hide_cursor if !cursor
      listen_mouse_events if !mouse
      # Allow special characters, don't show input from keyboard
      `stty raw -echo -icanon`
    end
    true
  end

  def inputthread(engine)
    Thread.new do
      loop do
        break unless $running
        char = STDIN.getc.chr
        if char == "\e"
          # Collect extra chars from the escape code
          # Can't loop for some reason.
          char << STDIN.read_nonblock(5) rescue nil
          char << STDIN.read_nonblock(4) rescue nil
          char << STDIN.read_nonblock(3) rescue nil
          char << STDIN.read_nonblock(2) rescue nil
        end
        key = input(char) if char
        Input.keys_down << key if key
        engine.last_key = key if key
        STDIN.getc while STDIN.ready?
      end
    rescue StandardError => e
      engine.quit
      puts "#{e.inspect}"
      puts e.backtrace
      engine.fullquit
    end
  end

  def input(key)
    case key
    when " " then :space
    when "\t" then :tab
    when "\r" then :enter
    when "\n" then :linefeed
    when "\e" then :escape
    when "\e[A" then :up
    when "\e[B" then :down
    when "\e[C" then :right
    when "\e[D" then :left
    when "\e[1;2A" then :shift_up
    when "\e[1;2B" then :shift_down
    when "\e[1;2C" then :shift_right
    when "\e[1;2D" then :shift_left
    when "\177", "\004", "\e[3~" then :backspace
    when "\u0003" then :control_c
    when /\e\[\d+;\d+;\d+M/
      _, evt, x, y = key.match(/\e\[(\d+);(\d+);(\d+)M/).to_a.map(&:to_i)
      x, y = x-1, y-1 # mouse is [1,1] based so convert to [0,0]
      x, y = Draw.offset_cell(x, y) if const_defined?(:Draw)
      $mousecoord = [x, y]
      case evt
      when 32 then "mousedown(#{x},#{y})"
      when 33 then "mousemiddledown(#{x},#{y})"
      when 35 then "mouseup(#{x},#{y})"
      when 36 then "mousedownShift(#{x},#{y})"
      when 37 then "mousemiddledownShift(#{x},#{y})"
      when 39 then "mouseupShift(#{x},#{y})" # Includes mouse middle and right
      when 40 then "mousedownCmd(#{x},#{y})"
      when 41 then "mousemiddledownCmd(#{x},#{y})"
      when 42 then "mouserightdownCmd(#{x},#{y})"
      when 43 then "mouseupCmd(#{x},#{y})"
      when 48 then "mouseWindowsCtrlDown(#{x},#{y})"
      when 50 then "mouserightCtrlDown(#{x},#{y})"
      when 51 then "mouserightCtrlUp(#{x},#{y})"
      when 64 then "mouseoverDown(#{x},#{y})"
      when 67 then "mouseoverUp(#{x},#{y})"
      when 71 then "mouseoverShift(#{x},#{y})"
      when 72 then "mousedragCmd(#{x},#{y})"
      when 74 then "mouserightCmdDrag(#{x},#{y})" # RightDrag + CMD
      when 75 then "mouseoverCmd(#{x},#{y})"
      when 79 then "mouseoverCmdShift(#{x},#{y})"
      when 83 then "mouseoverCtrl(#{x},#{y})"
      when 96 then "mousewheeldown(#{x},#{y})"
      when 97 then "mousewheelup(#{x},#{y})"
      when 100 then "shifttwofingerscrolldown(#{x},#{y})"
      when 101 then "shifttwofingerscrollup(#{x},#{y})"
      when 104 then "cmdtwofingerscrolldown(#{x},#{y})"
      when 105 then "cmdtwofingerscrollup(#{x},#{y})"
      when 112 then "ctrltwofingerscrolldown(#{x},#{y})"
      when 113 then "ctrltwofingerscrollup(#{x},#{y})"
      when 120 then "cmdctrltwofingerscrolldown(#{x},#{y})"
      when 121 then "cmdctrltwofingerscrollup(#{x},#{y})"
      else
        puts "\rMouse ELSE: [#{key.inspect}]"
      end
    when /^.$/ then key.to_sym
    else
      puts "\rSOMETHING ELSE: [#{key.inspect}]"
    end
  end
end
