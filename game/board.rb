class Board < InfiniBoard
  GROUND_LEVEL = -1
  ORE_RATIO = 0.15

  def self.create
    new(->(x, y) {
      return Block.base_from_type(:air) if y < GROUND_LEVEL # negative is up, positive is down

      dirt = (95 - ((GROUND_LEVEL + y) * 15)).clamp(5, 95) # 95% at surface, 15% less each layer down - minimum of 5%
      if Calc.rand_percent(dirt)
        Block.base_from_type(:dirt_invis)
      elsif Calc.rand_percent(15)
        Block.base_from_type(:ore_invis)
      else
        Block.base_from_type(:stone_invis)
      end
    })
  end

  def clear(x, y)
    set([x, y], Block.base_from_type(:air))
  end

  def air?(x, y)
    at(x, y).is?(Air)
  end

  def solid?(x, y)
    at(x, y).solid?
  end

  def exposed?(x, y)
    (-1..1).each { |rx| (-1..1).each { |ry|
      next if rx == 0 && ry == 0 # skip current block
      return true unless solid?(x+rx, y+ry)
    } }
    false
  end
end
