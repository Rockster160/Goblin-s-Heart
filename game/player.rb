require_relative "thing"

class Player < Thing
  attr_accessor :board

  REACH = 3

  def tick
    did_move = !@jumping && !grounded? && move(0, +1) # apply gravity if in the air
    @jumping = false # reset jumping state so gravity can apply again
    did_move
  end

  def move(relx, rely)
    nx, ny = [x + relx, y + rely]
    # Moving sideways, but there is a block in the way.
    # Check the space above instead and attempt to auto-jump
    ny -= 1 if relx != 0 && @board.solid?(nx, ny)

    # There's a block in the way. Cannot move
    return false if @board.solid?(nx, ny)

    self.coord = [nx, ny]
    true
  end

  def grounded?
    !@jumping && @board.at(@x, @y+1) != Block::AIR || @board.at(@x, @y) == Block::LADDER
  end

  def jump
    # @jumping prevents gravity from applying the next tick
    @jumping = true if grounded? && move(0, -1)
  end

  def can_reach?(rx, ry)
    (@x - rx).abs <= REACH && (@y - ry).abs <= REACH
  end
end
