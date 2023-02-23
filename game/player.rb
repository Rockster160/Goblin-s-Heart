# Not the right place for this- maybe should be it's own class, or just an enum on Player?
module Modes
  WALK  = 1
  MINE  = 2
  # PLACE = 3
end

class Player
  include Coord
  attr_accessor :icon, :board, :inventory, :reach, :mode, :jumping

  def initialize
    self.coord = [0, Board::GROUND_LEVEL-1]
    @icon = Dir.pwd.include?("rocco") ? "＠" : " 🯅"
    @inventory = []
    @reach = 3
    @mode = Modes::WALK
  end

  def mode_icon
    case @mode
    when Modes::MINE then "⸕"
    when Modes::WALK then "⬌"
    end
  end

  def tick
    did_move = !@jumping && fall # Apply gravity if in the air and not trying to jump
    @jumping = false # Reset jumping state so gravity can apply again
    did_move # Return whether or not gravity applied
  end

  def place_ladder(rel_x, rel_y)
    return unless can_reach?(rel_x, rel_y)
    map_x, map_y = rel_x + @x, rel_y + @y
    return unless @board.air?(map_x, map_y) # Cannot place on top of an existing block
    return if @board.air?(map_x, map_y+1) # Must have a non-air block below

    @board.set([map_x, map_y], Ladder.new)
  end

  def try_action(rel_x, rel_y)
    case @mode
    when Modes::WALK then try_move(rel_x, rel_y)
    when Modes::MINE then try_mine(rel_x, rel_y)
    end
  end

  def try_move(rel_x, rel_y)
    nx, ny = [@x + rel_x, @y + rel_y]
    walking = rel_x != 0
    # if walk is blocked and space is available to step up, then change position to the step up
    # Check the space above attempted block as well as above head
    ny -= 1 if walking && @board.solid?(nx, ny) && !@board.solid?(@x, @y-1)

    # There's a block in the way. Cannot move
    return false if @board.solid?(nx, ny)

    self.coord = [nx, ny]
    true
  end

  def jump
    # @jumping prevents gravity from applying the next tick
    @jumping = true if grounded? && try_move(0, -1)
  end

  def fall
    return false unless @board.at(@x, @y+1).air?

    try_move(0, +1)
  end

  # FIXME somehow this offset the clicky mining
  def try_mine(rel_x, rel_y)
    map_x, map_y = rel_x + @x, rel_y + @y
    block = @board.at(map_x, map_y)

    try_move(rel_x, rel_y) if @mode == Modes::MINE && !block.solid?
    return unless block.solid?

    if can_mine?(rel_x, rel_y)
      @inventory += [block.drops].flatten.compact
      @board.clear(map_x, map_y)
    end
  end

  def grounded?
    !@jumping && (!@board.at(@x, @y+1).air? || @board.at(@x, @y).is?(Ladder))
  end

  def can_reach?(rel_x, rel_y)
    Calc.distance(@x, @y, @x + rel_x, @y + rel_y) <= reach
  end

  def can_mine?(rel_x, rel_y)
    can_reach?(rel_x, rel_y) # && tool or something?
  end
end
