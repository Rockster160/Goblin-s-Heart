class InfiniBoard
  attr_accessor :grid, :minx, :miny, :maxx, :maxy

  def initialize(default_val=nil)
    @default_val = default_val
    @minx = nil
    @miny = nil
    @maxx = nil
    @maxy = nil
    val = default_val.is_a?(Proc) ? nil : default_val
    @grid = Hash.new { Hash.new(val) }
  end

  def at(x, y)
    @grid[y][x] || set([x, y], @default_val&.call(x, y, self))
  end

  def width
    @maxx - @minx + 1
  end

  def height
    @maxy - @miny + 1
  end

  def set(point, val)
    x, y = point
    # Need verbose here to properly set val
    row = @grid[y]
    row[x] = val
    @grid[y] = row

    @minx = x if @minx.nil? || x < @minx
    @maxx = x if @maxx.nil? || x > @maxx
    @miny = y if @miny.nil? || y < @miny
    @maxy = y if @maxy.nil? || y > @maxy
    val
  end

  def area(xrange, yrange)
    yrange.map do |y|
      xrange.map do |x|
        at(x, y)
      end
    end
  end

  def to_a
    @width = width
    @height = height

    @height.times.map do |y|
      @width.times.map do |x|
        at(x+@minx, y+@miny)
      end
    end
  end
end
