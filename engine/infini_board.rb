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
    @grid[y][x] || set([x, y], @default_val&.call(x, y))
  end

  def width
    @maxx - @minx + 1
  end

  def height
    @maxy - @miny + 1
  end

  def set(point, val)
    row = @grid[point[1]]
    row[point[0]] = val
    @grid[point[1]] = row

    @minx = point[0] if @minx.nil? || point[0] < @minx
    @maxx = point[0] if @maxx.nil? || point[0] > @maxx
    @miny = point[1] if @miny.nil? || point[1] < @miny
    @maxy = point[1] if @maxy.nil? || point[1] > @maxy
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
