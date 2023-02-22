require_relative "thing"

module Modes
  WALK  = 1
  MINE  = 2
  # PLACE = 3
end

class Player < Thing
  attr_accessor :board, :inventory, :reach, :mode

  
  def initialize(x, y, icon)
    super(x, y, icon)
    
    @inventory = []
    @reach = 3
    @mode = Modes::WALK
  end

  def tick
    did_move = !@jumping && !grounded? && move(0, +1) # apply gravity if in the air
    @jumping = false # reset jumping state so gravity can apply again
    did_move
  end

  def move(relx, rely)


    try_mine(relx, rely) if mode == Modes::MINE
     
    try_walk(relx, rely) if mode == Modes::WALK

  end

  def try_walk(relx, rely)
    nx, ny = [x + relx, y + rely]
    # Moving sideways, but there is a block in the way.
    # Check the space above instead and attempt to auto-jump
    ny -= 1 if relx != 0 && @board.solid?(nx, ny)

    # There's a block in the way. Cannot move
    return false if @board.solid?(nx, ny)

    self.coord = [nx, ny]
    true
  end

  # TODO this is sleepy code, take a look at it later
  # FIXME somehow this offset the clicky mining
  # FIXME physics do not apply when in mining mode?
  def try_mine(relx, rely)
    block_x, block_y = relx + x, rely + y 
    block = @board.at(block_x, block_y)

    # moving into empty space
    if block == Block::AIR[:char]
      try_walk(relx, rely)

    elsif can_reach?(block_x, block_y) && can_mine?(block_x, block_y)

      #  mining ore
      if block == Block::ORE[:char]
        inventory << {name: "ore", weight: 1}

        # drop stone sometimes when mining ore
        if rand(10) == 0
          inventory << {name: "stone", weight: 1}
        end
      end

      # mining stone
      # TODO extract this into better drop rate logic
      if block == Block::STONE[:char] && rand(10) >= 2
        inventory << {name: "stone", weight: 1}
      end

      @board.set([block_x, block_y], Block::AIR)
    end
  end


  def grounded?
    !@jumping && @board.at(@x, @y+1) != Block::AIR[:char] || @board.at(@x, @y) == Block::LADDER[:ladder]
  end

  def jump
    # @jumping prevents gravity from applying the next tick
    @jumping = true if grounded? && move(0, -1)
  end

  def can_reach?(rx, ry)
    (@x - rx).abs <= reach && (@y - ry).abs <= reach
  end

  def can_mine?(rx, ry)
    true
  end
end
