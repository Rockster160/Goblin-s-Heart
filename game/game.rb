require_relative "../engine/engine"
require_relative "../engine/infini_board"

Dir.chdir("./game")
Dir["*.rb"].each do |file|
  require_relative "./#{file}" if File.file?(file)
end

class Game
  attr_accessor :board, :player

  VIS_RANGE = 10

  def initialize
    @board = Board.create
    @player = Player.new(0, Board::GROUND_LEVEL-1, "＠")
    @player.board = @board
  end

  def tick
    draw if @player.tick # returns a bool if there was a change so we know to redraw screen
  end

  def draw
    minx = @player.x - VIS_RANGE
    maxx = @player.x + VIS_RANGE
    miny = @player.y - VIS_RANGE
    maxy = @player.y + VIS_RANGE

    brown = rgb(244, 164, 96)
    unshown = rgb(50, 50, 50)

    visible_blocks = []
    (minx..maxx).map { |x| (miny..maxy).map { |y|
      cell = @board.at(x, y)
      next unless Block::SOLIDS.include?(cell)

      coord = [x, y]
      if @board.exposed?(*coord)
        fg, bg = brown, nil
        # FIXME - background brown is slightly different to normal brown
        fg, bg = :silver, brown if cell == Block::ORE
        board_coord = [VIS_RANGE + coord[0] - @player.x, VIS_RANGE + coord[1] - @player.y]
        visible_blocks << [cell, board_coord, fg, bg]
      end
    } }.flatten.compact

    Draw.board(@board.area(minx..maxx, miny..maxy)) do |pencil|
      pencil.bg = :grey
      pencil.object(@player.icon, [VIS_RANGE, VIS_RANGE], :cyan)
      pencil.color_sprite(Block::LADDER, brown)

      pencil.sprite(Block::GROUND, Block::GROUND, unshown)
      pencil.sprite(Block::ORE, Block::GROUND, unshown)
      visible_blocks.each do |cell, board_coord, fg, bg|
        pencil.object(cell, board_coord, fg, bg: bg)
      end
    end
  end

  def input(key)
    # Engine.prepause; $done || ($done ||= true) && binding.pry; Engine.postpause
    case key
    when :a, :left  then @player.move(-1,  0)
    when :d, :right then @player.move(+1,  0)
    when :w, :up, :space then @player.jump
    when :s, :down  then @player.move( 0, +1)
    else
      # return puts(key) # uncomment for debugging to see which events are being triggered
    end

    draw
  end

  def instant_input(key) # Triggers as soon as it happens
    case key
    when /mousedown\(/
      _, drawx, drawy = key.to_s.match(/mousedown\((-?\d+),(-?\d+)\)/).to_a.map(&:to_i)
      x, y = [drawx-VIS_RANGE+@player.x, drawy-VIS_RANGE+@player.y]
      @board.set([x, y], Block::AIR) if @player.can_reach?(x, y)
    when /mousedownShift\(/
      _, drawx, drawy = key.to_s.match(/mousedownShift\((-?\d+),(-?\d+)\)/).to_a.map(&:to_i)
      x, y = [drawx-VIS_RANGE+@player.x, drawy-VIS_RANGE+@player.y]
      @board.set([x, y], Block::LADDER) if @player.can_reach?(x, y)
    end
  end
end
