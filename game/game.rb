require_relative "../engine/engine"
require_relative "../engine/infini_board"
# require "pry-rails"; binding.pry
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




    color_brown   = rgb(244, 164, 96)
    color_unshown = "#090a14"
    color_stone   = "#202e37"
    color_dirt    = "#884b2b"
    color_sand    = "#e8c170"
    color_ore     = "#c7cfcc"
    color_air     = "#a4dddb"
    color_player  = "#253a5e"

    visible_blocks = []
    (minx..maxx).map { |x| (miny..maxy).map { |y|
      cell_char = @board.at(x, y)
      # TODO refactor this so board at checks the map
      # not the rendered board, in case we don't wanne render the right tile yet
      next unless Block::SOLIDS.any? { |solid| solid[:char] == cell_char }

      coord = [x, y]
      
      if @board.exposed?(*coord)
        fg, bg = color_stone, color_stone
        # fg, bg = color_ore, color_stone if cell_char == Block::ORE

        board_coord = [VIS_RANGE + coord[0] - @player.x, VIS_RANGE + coord[1] - @player.y]
        visible_blocks << [cell_char, board_coord, fg, bg]
      end
    } }.flatten.compact

    Draw.board(@board.area(minx..maxx, miny..maxy)) do |pencil|

      pencil.bg = color_air
      pencil.paint(@player.icon, [VIS_RANGE, VIS_RANGE], color_player)
      pencil.recolor(Block::LADDER[:char], color_brown)
      pencil.recolor(Block::ORE[:char], color_unshown, bg: color_unshown)
      pencil.recolor(Block::STONE[:char], color_unshown, bg: color_unshown)

      # puts(visible_blocks)
      visible_blocks.each do |cell_char, board_coord, fg, bg|
        fg, bg = color_ore, color_stone if cell_char == Block::ORE[:char]
        fg, bg = color_stone, color_stone if cell_char == Block::STONE[:char]

        pencil.paint(cell_char, board_coord, fg, bg: bg)
      end
    end
  end

  def input(key) # Triggers only once per tick with the most recent key pressed
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
