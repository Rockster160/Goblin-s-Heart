class Board < InfiniBoard
  GROUND_LEVEL = -1
  ORE_RATIO = 0.15

  def self.create
    new(->(x, y, board) {
      return Block.base_from_type(:air) if y < GROUND_LEVEL # negative is up, positive is down

      dirt = (95 - ((GROUND_LEVEL + y) * 15)).clamp(5, 95) # 95% at surface, 15% less each layer down - minimum of 5%
      
      # neighbor logic
      sand_neighbor = false 
      if board.grid.dig(y, x - 1)&.is?(Sand) || board.grid.dig(y, x + 1)&.is?(Sand)
        sand_neighbor = true
      elsif board.grid.dig(y - 1, x)&.is?(Sand) || board.grid.dig(y + 1, x)&.is?(Sand)
        sand_neighbor = true
      end

      if Calc.rand_one_in(2)
        sand_neighbor = false
      end

      if Calc.rand_percent(dirt)
        Block.base_from_type(:dirt_invis)
      elsif Calc.rand_percent(5)
        Block.base_from_type(:ore_invis)
      elsif Calc.rand_percent(10) || sand_neighbor
        Block.base_from_type(:sand_invis)
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
