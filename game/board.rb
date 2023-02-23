class Board < InfiniBoard
  GROUND_LEVEL = -1
  ORE_RATIO = 0.15

  def self.create
    new(->(x, y) {
      return Block.base_from_type(:air) if y < GROUND_LEVEL # negative is up, positive is down
      Calc.rand_ratio(0.15) ? Block.base_from_type(:ore_invis) : Block.base_from_type(:stone_invis)
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
