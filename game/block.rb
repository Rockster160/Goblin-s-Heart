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

  def self.register_klass(klass_name=nil)
    klass_name ||= klass_snakecase(klass_name)
    @@block_types[klass_name] = self.new(visible: true)
    return if @opts[:visible]

    @@block_types["#{klass_name}_invis".to_sym] = self.new
  end

  def self.register(klass_name, class_opts, &block)
    klass_name = klass_snakecase(klass_name)
    klass = Object.const_set(
      klass_pascalcase(klass_name),
      Class.new(self) do
        block_data(**class_opts)
        block&.call
      end
    )
    klass.register_klass(klass_name)
  end

  def self.all = @blocks
  def self.base_from_type(klass_name_sym) = @@block_types[klass_name_sym]
  def self.base = @@block_types[klass_snakecase]
  def self.invis = @@block_types["#{klass_snakecase}_invis".to_sym]
  def self.glint_char = @opts[:glint_block]

  def self.klass_pascalcase(klass_name=nil)
    (klass_name || self.name).to_s.downcase.split("_").map(&:capitalize).join("").to_sym
  end
  def self.klass_snakecase(klass_name=nil)
    snake = (klass_name || self.name).to_s.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    snake.to_sym
  end

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
  def air? = (is?(Air) || is?(CaveAir))
  def solid? = @solid
  def visible? = @visible
  def invisible? = !@visible
  def glintable? = copts[:glintable]
  def is?(klass) = is_a?(klass)
  def name = self.class.name.downcase.to_sym
  def render_name = copts[:render_name] || name.capitalize
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

def drop_seed
  Calc.rand_by_weight(
    SeedHemp => SeedHemp[:drop_chance],
    SeedBerries => SeedBerries[:drop_chance],
    SeedFlower => SeedFlower[:drop_chance],
    SeedHerb => SeedHerb[:drop_chance],
    SeedWheat => SeedWheat[:drop_chance]
  )
end

Block.register(:air, item: "", char: "  ", fg: Palette.air, solid: false, visible: true)
Block.register(:cave_air, item: "", char: "  ", fg: Palette.cave_air, bg: Palette.cave_air, solid: false, visible: true)
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
    stack << drop_seed.new # Drop seeds sometimes when mining dirt
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
  :seed_hemp, item: "ϫ", drop_chance: 3, render_name: "Hemp Seed",
  growth_levels: [
    {char: ".", fg: ""},
    {char: "ϫ", fg: ""},
    {char: "Ϫ", fg: ""},
    {char: "𝚼", fg: ""}
    ])
Block.register(
  :seed_berries, item: "ѵ", drop_chance: 2, render_name: "Berry Bush Seed",
  growth_levels: [
    {char: ".", fg: ""},
    {char: "ѵ", fg: ""},
    {char: "Ѵ", fg: ""},
    {char: "Ѷ", fg: ""}
])
Block.register(
  :seed_flower, item: "ᛙ", drop_chance: 1, render_name: "Flower Seed",
  growth_levels: [
    {char: ".", fg: ""},
    {char: "ᛙ", fg: ""},
    {char: "⚘", fg: ""}
])
  Block.register(
  :seed_herb, item: "℩", drop_chance: 1, render_name: "Herb Seed",
  growth_levels: [
    {char: ".", fg: ""},
    {char: "℩", fg: ""},
    {char: "ጉ", fg: ""},
    {char: "ᒓ", fg: ""}
    ])
Block.register(
  :seed_wheat, item: "…", drop_chance: 4, render_name: "Wheat Seed",
  growth_levels: [
    {char: "…", fg: ""},
    {char: "꠲", fg: ""},
    {char: "ꔖ", fg: ""},
    {char: "ⅲ", fg: ""}
])
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
