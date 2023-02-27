require_relative "coord"
require_relative "palette"

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

  def self.register_klass(klass, klass_name=nil)
    klass_name ||= klass.name.to_s.downcase.to_sym
    @@block_types[klass_name] = klass.new(visible: true)
    return if @opts[:visible]

    @@block_types["#{klass_name}_invis".to_sym] = klass.new
  end

  def self.register(klass_name, class_opts, &block)
    klass = Object.const_set(
      klass_name.to_s.capitalize,
      Class.new(self) do
        block_data(**class_opts)
        block&.call
      end
    )
    register_klass(klass, klass_name)
  end

  def self.all = @blocks
  def self.base_from_type(klass_sym) = @@block_types[klass_sym]
  def self.base = @@block_types[self.name.downcase.to_sym]
  def self.invis = @@block_types["#{self.name.downcase}_invis".to_sym]
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

  def self.opts = @opts
  def self.[](opt) = @opts[opt]
  def copts = self.class.opts

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
  def air? = is?(Air)
  def solid? = @solid
  def visible? = @visible
  def invisible? = !@visible
  def glintable? = copts[:glintable]
  def is?(klass) = is_a?(klass)
  def name = self.class.name.downcase.to_sym
  def to_s
    return @visible ? copts[:visible_block] : copts[:invisible_block] if copts[:char] == @opts[:char]

    @char.then { |str|
      str = Draw.draw(str)
      str = Colorize.color(@bg, str, :bg) if @bg
      str = Colorize.color(@fg, str, :fg) if @fg
      str
    }
  end
  # def to_s = @visible ? copts[:visible_block] : copts[:invisible_block]
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
Block.register(:sand, item: "", char: "⸫⸪", fg: Palette.sand_dark, bg: Palette.sand)#, gravity: true
Block.register(:dirt, item: "", char: "⁙⁛", fg: Palette.stone, bg: Palette.dirt)
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
  fg_glint: Palette.ore_glow,
  drops: ->(stack) {
    stack << Ore.new
    stack << Stone.new if Calc.rand_percent(10) # Drop stone sometimes when mining ore
  }
)
