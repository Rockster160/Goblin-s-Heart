class Player
  extend Enum
  include Coord
  attr_accessor :icon, :board, :inventory, :reach, :mode, :jumping

  enum mode: [:walk, :place, :mine, :menu]

  def initialize
    self.coord = [0, Board::GROUND_LEVEL-1]
    # @icon = Dir.pwd.include?("rocco") ? "＠" : " 🯅"
    @icon = Dir.pwd.include?("rocco") ? "𐂀" : " 🯅"
    @inventory = []
    @reach = 3
    @glint_range = 5
    @jumping = 0
    walk!
  end

  def tick
    if @jumping > 0
      did_move = lift
      @jumping -= 1
    else
      did_move = fall
      @jumping = 0
    end

    did_move # Return whether or not gravity applied
  end

  def interact
  end

  def place_ladder(rel_x, rel_y)
    return unless can_reach?(rel_x, rel_y)
    map_x, map_y = rel_x + @x, rel_y + @y
    return unless $board.air?(map_x, map_y) # Cannot place on top of an existing block
    return if $board.air?(map_x, map_y+1) # Must have a non-air block below

    $board.set([map_x, map_y], Ladder.new)
  end

  def try_action(rel_x, rel_y)
    if mine?
      try_mine(rel_x, rel_y)
    else
      try_move(rel_x, rel_y)
    end
  end

  def try_move(rel_x, rel_y)
    nx, ny = [@x + rel_x, @y + rel_y]
    walking = rel_x != 0
    # if walk is blocked and space is available to step up, then change position to the step up
    # Check the space above attempted block as well as above head
    ny -= 1 if walking && $board.solid?(nx, ny) && !$board.solid?(@x, @y-1)

    # There's a block in the way. Cannot move
    return false if $board.solid?(nx, ny)

    self.coord = [nx, ny]
    true
  end

  def jump
    # @jumping prevents gravity from applying the next tick
    @jumping = 2 if grounded?
  end

  def sturdy?(x, y)
    block = $board.at(x, y)

    return false if block.air?
    return true if block.ladder?

    block.is?(Water) && block.level >= 6
  end

  def lift
    if !$board.at(@x, @y-1).solid?
      try_move(0, -1)
    else
      @jumping = 0
      return false
    end
  end

  def fall
    return false if sturdy?(@x, @y+1)

    try_move(0, +1)
  end

  def try_mine(rel_x, rel_y)
    map_x, map_y = rel_x + @x, rel_y + @y
    block = $board.at(map_x, map_y)

    try_move(rel_x, rel_y) if mine? && !block.solid?
    return unless block.solid?

    if can_mine?(rel_x, rel_y)
      @inventory += block.drops
      $board.clear(map_x, map_y)
    end
  end

  def grounded?
    return false unless @jumping == 0

    !$board.at(@x, @y+1).air? || $board.at(@x, @y).is?(Ladder)
  end

  def can_reach?(rel_x, rel_y)
    Calc.distance(@x, @y, @x + rel_x, @y + rel_y) <= @reach
  end

  def within_glint_range?(rel_x, rel_y)
    Calc.distance(@x, @y, @x + rel_x, @y + rel_y) <= @glint_range
  end

  def can_mine?(rel_x, rel_y)
    can_reach?(rel_x, rel_y) # && tool or something?
  end
end
