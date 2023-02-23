require_relative "coord"
require_relative "palette"

class Block
  attr_accessor :item, :char, :fg, :bg, :weight, :solid, :visible
  @opts = {}
  # @@blocks = [] # All blocks
  # @blocks = [] # Blocks per class

  # def self.add(block)
  #   @blocks << block
  #   @@blocks << block
  # end

  def self.register(class_opts)
    Class.new(self) do
      block_data **class_opts
    end
  end

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
  # def self.drops(drop_proc) = @opts[:drops] = drop_proc
  def self.[](opt) = @opts[opt]
  def copts = self.class.opts

  def initialize
    @item = copts[:item] || ""
    @char = copts[:char] || "."
    @fg = copts[:fg] || nil
    @bg = copts[:bg] || nil
    @weight = copts[:weight] || 1
    @solid = copts.key?(:solid) ? copts[:solid] : true
    @visible = copts.key?(:visible) ? copts[:visible] : false
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

Air = Block.register(item: "", char: "  ", fg: Palette.air, solid: false, visible: true)
Block::AIR = Air.new # Used so we only have one reference to air. Save some memory.
Stone = Block.register(
  item: "⬢",
  char: "  ",
  bg: Palette.stone,
  drops: ->(stack) {
    stack << Stone.new if Calc.rand_percent(10)
  }
)
Ore = Block.register(
  item: "⠶",
  char: "⠰⠆",
  fg: Palette.ore,
  bg: Palette.stone,
  drops: ->(stack) {
    stack << Ore.new
    stack << Stone.new if Calc.rand_percent(10) # Drop stone sometimes when mining ore
  }
)
Sand = Block.register(item: "", char: "▒▒", fg: Palette.sand)#, gravity: true
Dirt = Block.register(item: "", char: "▓▓", fg: Palette.dirt)
# Grass = Block.register(item: "", char: "▔▔", fg: Palette.grass)
Ladder = Block.register(item: "ℍ", char: "╂╂", fg: Palette.brown, solid: false)
