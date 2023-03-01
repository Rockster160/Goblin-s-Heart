require_relative "../lib/coord"
require_relative "../lib/palette"
require_relative "../lib/text"

class Block
  attr_accessor :item, :char, :fg, :bg, :weight, :solid, :visible
  @opts = {}
  @@block_types = {}
  @@blocks = [] # All blocks
  @blocks = [] # Blocks per class

  def self.add(block)
    @blocks ||= []
    @blocks << block
    @@blocks ||= []
    @@blocks << block
  end

  def self.register_class(klass_name=nil)
    klass = self
    klass_name ||= Text.snake(klass_name || self.name).to_sym
    @@block_types[klass_name] = klass.new(visible: true)
    Block.define_method("#{klass_name}?") { is?(klass) }
    return if @opts[:visible]

    @@block_types["#{klass_name}_invis".to_sym] = self.new
  end

  def self.register(klass_name, class_opts, &block)
    klass_name = Text.snake(klass_name || self.name).to_sym
    klass = Object.const_set(
      Text.pascal(klass_name),
      Class.new(self) do |new_klass|
        block_data(**class_opts)
        block&.call(new_klass)
      end
    )
    klass.register_class(klass_name)
  end

  def self.all = @blocks
  def self.base = @@block_types[Text.snake(self.name).to_sym]

  def self.invis
    @@block_types["#{Text.snake(self.name)}_invis".to_sym]
  end

  def self.glint_char = @opts[:glint_block]

  def self.block_data(opts)
    @opts = opts
    @opts[:visible_block] = (opts[:char] || "").then { |str|
      str = Draw.draw(str)
      str = Colorize.color(opts[:bg], str, :bg) if opts[:bg]
      str = Colorize.color(opts[:fg], str, :fg) if opts[:fg]
      str
    }
    @opts[:invisible_block] = (opts[:invis_char] || opts[:char] || "").then { |str|
      str = Draw.draw(str)
      str = Colorize.color(opts[:bg_invis] || Palette.invisible, str, :bg)
      str = Colorize.color(opts[:fg_invis] || Palette.invisible, str, :fg)
    }
    @opts[:glint_block] = (opts[:glint_char] || opts[:invis_char] || opts[:char] || "").then { |str|
      str = Draw.draw(str)
      str = Colorize.color(opts[:bg_glint] || opts[:bg_invis] || Palette.invisible, str, :bg)
      str = Colorize.color(opts[:fg_glint] || opts[:fg_invis] || Palette.invisible, str, :fg)
    }
    @opts[:glintable] = !!(opts[:glint_char] || opts[:bg_glint] || opts[:fg_glint])
  end

  def self.opts = @opts || {}
  def self.[](opt) = @opts[opt]
  def copts = self.class.opts || {}

  def initialize(opts={})
    @opts = opts
    @item = opts[:item] || copts[:item] || ""
    @char = opts[:char] || copts[:char] || "."
    @fg = opts[:fg] || copts[:fg] || nil
    @bg = opts[:bg] || copts[:bg] || nil
    @weight = opts[:weight] || copts[:weight] || 1
    @solid = bool_opt?(opts, :solid, true)
    @visible = bool_opt?(opts, :visible)
    @glint = bool_opt?(opts, :glint)
    self.class.add(self)
  end

  def tick(x, y); end # Empty method - should be overridden by classes
  def solid? = @solid
  def visible? = @visible
  def invisible? = !@visible
  def glintable? = copts[:glintable]
  def is?(klass) = is_a?(klass)
  def name = self.class.name.downcase.to_sym
  def render_name = copts[:render_name] || Text.title(name)

  def to_s
    return copts[:invisible_block] if !@visible
    return copts[:visible_block] if copts[:char] == @opts[:char]

    @char.then { |str|
      str = Draw.draw(str)
      str = Colorize.color(@bg, str, :bg) if @bg
      str = Colorize.color(@fg, str, :fg) if @fg
      str
    }
  end

  def drops
    return [self.class.new] unless copts.key?(:drops)

    [].tap { |stack| copts[:drops]&.call(stack) }.flatten.compact
  end

  def bool_opt?(opts, key, default=false)
    return opts[key] if opts.key?(key)

    copts.key?(key) ? copts[key] : default
  end
end

Block.register(:air, item: "", char: "  ", fg: Palette.air, solid: false, visible: true)
Block.register(
  :sand,
  item: "▢",
  char: "⸫⸪",
  fg: Palette.sand_dark,
  bg: Palette.sand,
)#, gravity: true
Block.register(
  :dirt,
  render_name: "Dort",
  item: "🞔",
  char: "⁙⁛",
  fg: Palette.stone,
  bg: Palette.dirt,
  drops: -> (stack) {
    stack << Dirt.new
    stack << Seed.random_drop.new # Drop seeds sometimes when mining dirt
  }
)
# Block.register(:grass, item: "", char: "▔▔", fg: Palette.grass)
Block.register(:ladder, item: "ℍ", char: "╂╂", fg: Palette.brown, solid: false)
Block.register(
  :stone,
  item: "▣",
  char: "  ",
  bg: Palette.stone,
  drops: ->(stack) {
    stack << Stone.new if Calc.rand_percent(90)
  }
)
Block.register(
  :ore,
  render_name: "Iron Ore",
  item: "⠶",
  char: "⠰⠆",
  fg: Palette.ore,
  bg: Palette.stone,
  fg_glint: Palette.ore_glow,
  drops: ->(stack) {
    stack << Ore.new
    stack << Stone.new if Calc.rand_percent(10) # Drop stone sometimes when mining ore
  }
)
class CaveAir < Air
  block_data item: "", char: "  ", fg: Palette.cave_air, bg: Palette.cave_air, solid: false, visible: true
  register_class
end
