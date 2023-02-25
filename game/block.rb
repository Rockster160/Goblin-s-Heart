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
    return if class_opts[:visible]

    @@block_types["#{klass_name}_invis".to_sym] = klass.new
  end

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

  def bool_opt?(opts, key, default=false)
    return opts[key] if opts.key?(key)

    copts.key?(key) ? copts[key] : default
  end

  def initialize(opts={})
    @item = opts[:item] || copts[:item] || ""
    @char = opts[:char] || copts[:char] || "."
    @fg = opts[:fg] || copts[:fg] || nil
    @bg = opts[:bg] || copts[:bg] || nil
    @weight = opts[:weight] || copts[:weight] || 1
    @solid = bool_opt?(opts, :solid, true)
    @visible = bool_opt?(opts, :visible)
    @glint = bool_opt?(opts, :glint)
    # self.class.add(self)
  end

  def air? = is?(Air)
  def solid? = @solid
  def visible? = @visible
  def invisible? = !@visible
  def glintable? = copts[:glintable]
  def is?(klass) = is_a?(klass)
  def drops = [].tap { |stack| copts[:drops]&.call(stack) }.flatten.compact
  def name = self.class.name.downcase.to_sym
  def to_s = @visible ? copts[:visible_block] : copts[:invisible_block]
end

def drop_seed
 
  Calc.rand_get_choice(
    hemp: Seed_hemp[:drop_chance],
    berries: Seed_berries[:drop_chance],
    flower: Seed_flower[:drop_chance]
  )


end

Block.register(:air, item: "", char: "  ", fg: Palette.air, solid: false, visible: true)
Block.register(:sand, item: "", char: "⸫⸪", fg: Palette.sand_dark, bg: Palette.sand)#, gravity: true
Block.register(
  :dirt, 
  item: "", 
  char: "⁙⁛", 
  fg: Palette.stone, 
  bg: Palette.dirt,
  drops: -> (stack) {
    stack << Stone.new if Calc.rand_percent(25) # Drop seeds sometimes when mining dirt
  }
)
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
  :seed_hemp, 
  item: "ϫ", 
  drop_chance: 3, 
  growth_levels: [
    ".",
    "ϫ",
    "Ϫ",
    "𝚼"
    ])
Block.register(
  :seed_berries, 
  item: "ѵ", 
  drop_chance: 2, 
  growth_levels: [
    {char: ".", fg: ""},
    {char: "ѵ", fg: ""},
    {char: "Ѵ", fg: ""},
    {char: "Ѷ", fg: ""}
])
Block.register(
  :seed_flower, 
  item: "١", 
  drop_chance: 1, 
  growth_levels: [
    {char: ".", fg: ""},
    {char: "١", fg: ""},
    {char: "⚘", fg: ""}
])
  Block.register(
  :seed_herb, 
  item: "℩", 
  drop_chance: 1, 
  growth_levels: [
    {char: ".", fg: ""},
    {char: "℩", fg: ""},
    {char: "ጉ", fg: ""},
    {char: "ᒓ", fg: ""}
    ])
Block.register(
  :seed_wheat, 
  item: "…", 
  drop_chance: 4, 
  growth_levels: [
    {char: "…", fg: ""},
    {char: "꠲", fg: ""},
    {char: "ꔖ", fg: ""},
    {char: "ⅲ", fg: ""}
])
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
