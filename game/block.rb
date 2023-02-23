require_relative "coord"
require_relative "palette"

class Block
  attr_accessor :item, :char, :fg, :bg, :weight, :solid, :visible
  @opts = {}
  @@block_types = {}
  # @@blocks = [] # All blocks
  # @blocks = [] # Blocks per class

  # def self.add(block)
  #   @blocks << block
  #   @@blocks << block
  # end

  def self.register(klass_name, class_opts)
    klass = Object.const_set(
      klass_name.to_s.capitalize,
      Class.new(self) do
        block_data(**class_opts)
      end
    )
    @@block_types[klass_name] = klass.new(visible: true)
    @@block_types["#{klass_name}_invis".to_sym] = klass.new unless class_opts[:visible]
  end

  def self.base_from_type(klass_sym) = @@block_types[klass_sym]
  def self.base = @@block_types[self.name.downcase.to_sym]
  def self.base_invis = @@block_types["#{self.name.downcase}_invis".to_sym]

  def self.block_data(opts)
    @opts = opts
    @opts[:visible_block] = (opts[:char] || "").then { |str|
      str = Draw.draw(str)
      str = Colorize.color(opts[:bg], str, :bg) if opts[:bg]
      str = Colorize.color(opts[:fg], str, :fg) if opts[:fg]
      str
    }
    @opts[:invisible_block] = Colorize.color(Palette.invisible, Draw.draw(""), :bg)
  end

  def self.opts = @opts
  def self.[](opt) = @opts[opt]
  def copts = self.class.opts

  def initialize(opts={})
    @item = opts[:item] || copts[:item] || ""
    @char = opts[:char] || copts[:char] || "."
    @fg = opts[:fg] || copts[:fg] || nil
    @bg = opts[:bg] || copts[:bg] || nil
    @weight = opts[:weight] || copts[:weight] || 1
    if opts.key?(:solid)
      @solid = opts[:solid]
    else
      @solid = copts.key?(:solid) ? copts[:solid] : true
    end
    if opts.key?(:visible)
      @visible = opts[:visible]
    else
      @visible = copts.key?(:visible) ? copts[:visible] : false
    end
    # self.class.add(self)
  end

  def air? = is?(Air)
  def solid? = @solid
  def visible? = @visible
  def invisible? = !@visible
  def is?(klass) = is_a?(klass)
  def drops = [].tap { |stack| copts[:drops]&.call(stack) }.flatten.compact
  def name = self.class.name.downcase.to_sym
  def to_s = @visible ? copts[:visible_block] : copts[:invisible_block]
end

Block.register(:air, item: "", char: "  ", fg: Palette.air, solid: false, visible: true)
Block.register(:sand, item: "", char: "▒▒", fg: Palette.sand)#, gravity: true
Block.register(:dirt, item: "", char: "▓▓", fg: Palette.dirt)
# Block.register(:grass, item: "", char: "▔▔", fg: Palette.grass)
Block.register(:ladder, item: "ℍ", char: "╂╂", fg: Palette.brown, solid: false)
Block.register(
  :stone,
  item: "⬢",
  char: "  ",
  bg: Palette.stone,
  drops: ->(stack) {
    stack << Stone.new if Calc.rand_percent(10)
  }
)
Block.register(
  :ore,
  item: "⠶",
  char: "⠰⠆",
  fg: Palette.ore,
  bg: Palette.stone,
  drops: ->(stack) {
    stack << Ore.new
    stack << Stone.new if Calc.rand_percent(10) # Drop stone sometimes when mining ore
  }
)
