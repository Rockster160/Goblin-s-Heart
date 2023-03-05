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

  # TODO add gradient using ░▒▓█
  def clear(x, y)
    air_type = y > (GROUND_LEVEL+10) || !has_skylight?(x, y) ? CaveAir.base : Air.base 
    set([x, y], air_type)

    clear(x, y + 1) if at(x, y + 1).air?
  end

  def air?(x, y)
    at(x, y).then { |block| block.is?(Air) }
  end

  def has_skylight?(x, y)
    check_y = y.dup
    loop do
      check_y -= 1
      return false if at(x, check_y).solid?
      return true if check_y < GROUND_LEVEL-4
    end
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
