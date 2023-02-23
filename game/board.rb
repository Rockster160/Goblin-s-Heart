class Board < InfiniBoard
  GROUND_LEVEL = -1
  ORE_RATIO = 0.15

  def self.create
    new(->(x, y) {
      return Block::AIR[:char] if y < GROUND_LEVEL # negative is up, positive is down
      rand(100) < (ORE_RATIO*100) ? Block::ORE[:char] : Block::STONE[:char]
    })
  end

  def solid?(x, y)
    Block::SOLIDS.any? { |solid| solid[:char] == at(x, y) }
  end

  def exposed?(x, y)
    (-1..1).each { |rx| (-1..1).each { |ry|
      next if rx == 0 && ry == 0 # skip current block
      return true unless solid?(x+rx, y+ry)
    } }
    false
  end
end
