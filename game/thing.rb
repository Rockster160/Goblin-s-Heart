class Thing
  attr_accessor :x, :y, :icon

  def initialize(x, y, icon)
    @x = x
    @y = y
    @icon = icon
  end

  def coord
    [@x, @y]
  end

  def coord=(new_coord)
    @x, @y = *new_coord
  end
end
