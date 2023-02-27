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

  def area_map(xrange, yrange, &block)
    yrange.map do |y|
      xrange.map do |x|
        block.call(x, y)
      end
    end
  end

  def area_each(xrange, yrange, &block)
    xrange.each do |x|
      yrange.each do |y|
        block.call(x, y)
      end
    end; nil
  end

  def area(xrange, yrange) = area_map(xrange, yrange) { |x, y| at(x, y) }
  def to_a = area((@minx..@maxx), (@miny..@maxy))
  def reverse_each(&block) = area_each((@minx..@maxx).to_a.reverse, (@miny..@maxy).to_a.reverse) { |x, y| block.call(x, y) }
  def each(&block) = area_each((@minx..@maxx), (@miny..@maxy)) { |x, y| block.call(x, y) }
  def reverse_map(&block) = area_map((@minx..@maxx).to_a.reverse, (@miny..@maxy).to_a.reverse) { |x, y| block.call(x, y) }
  def map(&block) = area_map((@minx..@maxx), (@miny..@maxy)) { |x, y| block.call(x, y) }
end
