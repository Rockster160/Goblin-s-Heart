module Coord
  attr_accessor :x, :y

  def coord
    [@x, @y]
  end

  def coord=(new_coord)
    @x, @y = new_coord
  end
end
