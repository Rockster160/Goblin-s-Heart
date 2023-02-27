class Board < InfiniBoard
  GROUND_LEVEL = -1
  ORE_RATIO = 0.15

  def self.create
    new(->(x, y, board) {
      return Air.base if y < GROUND_LEVEL # negative is up, positive is down

      if Calc.rand_percent((95 - ((GROUND_LEVEL + y) * 15)).clamp(5, 95)) # 95% at surface, 15% less each layer down - minimum of 5%
        Dirt.invis
      elsif Calc.rand_percent(5)
        Ore.invis
      elsif gen_sand?(x, y, board) || Calc.rand_percent(10)
        Sand.invis
      else
        Stone.invis
      end
    })
  end

  def self.gen_sand?(x, y, board)
    sand_neighbor = board.grid.dig(y, x - 1)&.is?(Sand) || board.grid.dig(y, x + 1)&.is?(Sand)
    sand_neighbor ||= board.grid.dig(y - 1, x)&.is?(Sand) || board.grid.dig(y + 1, x)&.is?(Sand)
    sand_neighbor = false if sand_neighbor && Calc.rand_one_in(2)
    sand_neighbor
  end

  def tick
    did_move = false
    reverse_each do |map_x, map_y|
      did_move = true if at(map_x, map_y).tick(map_x, map_y)
    end
    did_move
  end

  def clear(x, y)
    set([x, y], Air.base)
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
