require_relative "block"

class Seed < Block
  @@seed_types = {}
  def self.drop_chance(chance) = @drop_chance = chance
  def self.growth_levels(*levels) = @growth_levels = levels
  def self.growth_levels(*levels) = @growth_levels = levels

  def self.register_class
    @@seed_types ||= {}
    @@seed_types[self] = @drop_chance
    super
  end

  def self.random_drop
    Calc.rand_by_weight(@@seed_types)
  end

  def render_name = "#{Text.title(self.class.name)} Seed"
end

class Hemp < Seed
  block_data item: "ϫ"
  drop_chance 3
  growth_levels(
    { char: "." },
    { char: "ϫ" },
    { char: "Ϫ" },
    { char: "𝚼" }
  )
  register_class
end

class BerryBush < Seed
  block_data item: "ѵ"
  drop_chance 2
  growth_levels(
    { char: "." },
    { char: "ѵ" },
    { char: "Ѵ" },
    { char: "Ѷ" }
  )
  register_class
end

class Flower < Seed
  block_data item: "ᛙ"
  drop_chance 1
  growth_levels(
    { char: "." },
    { char: "ᛙ" },
    { char: "⚘" }
  )
  register_class
end

class Herb < Seed
  block_data item: "℩"
  drop_chance 1
  growth_levels(
    { char: "." },
    { char: "℩" },
    { char: "ጉ" },
    { char: "ᒓ" }
  )
  register_class
end

class Wheat < Seed
  block_data item: "…"
  drop_chance 4
  growth_levels [
    { char: "…" },
    { char: "꠲" },
    { char: "ꔖ" },
    { char: "ⅲ" }
  ]
  register_class
end
