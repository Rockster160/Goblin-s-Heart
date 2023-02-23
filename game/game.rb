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
    @player = Player.new
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

    visible_board = @board.area(minx..maxx, miny..maxy)
    # Update which blocks are visible- once visible, blocks stay visible forever
    visible_board.each_with_index { |row, drawn_y| row.each_with_index { |block, drawn_x|
      next if block.visible?

      block.visible = true if @board.exposed?(*drawn_to_map(drawn_x, drawn_y))
    } }

    Draw.board(visible_board) do |pencil|
      pencil.bg = Palette.air
      pencil.paint(@player.icon, [VIS_RANGE, VIS_RANGE], Palette.player, bg: Palette.player_bg)

      mode_ui_coord = [1, 1]
      pencil.write(@player.mode_icon, mode_ui_coord, "#090a14")
    end

    # TODO extract this into a better UI
    inven_counts = @player.inventory.map(&:name).tally
    puts("#{Ore[:item]} #{inven_counts[:ore] || 0}")
    puts("#{Stone[:item]} #{inven_counts[:stone] || 0}")
    puts("#{Ladder[:item]} #{inven_counts[:ladder] || 0}")
    puts "Drawn: #{$mousecoord} - Map: #{drawn_to_map(*$mousecoord)}" if $mousecoord&.length == 2
    puts "Player: #{@player.coord}"
    $messages.each do |k, msg|
      puts msg
    end
  end

  def input(key)
    # Engine.prepause; $done || ($done ||= true) && binding.pry; Engine.postpause
    case key
    when :a, :left  then @player.try_action(-1,  0)
    when :d, :right then @player.try_action(+1,  0)
    when :space     then @player.jump
    when :w, :up    then @player.try_action( 0, -1)
    when :s, :down  then @player.try_action( 0, +1)
    when :e         then @player.mode = Modes::MINE
    when :q         then @player.mode = Modes::WALK
    else
      # return puts(key) # uncomment for debugging to see which events are being triggered
    end

    draw
  end

  def instant_input(key) # Triggers as soon as it happens
    case key
    when /mousedown\(/
      _, drawx, drawy = key.to_s.match(/mousedown\((-?\d+),(-?\d+)\)/).to_a.map(&:to_i)
      rel_x, rel_y = drawn_to_rel(drawx, drawy)

      @player.try_mine(rel_x, rel_y)
    when /mousedownShift\(/
      _, drawx, drawy = key.to_s.match(/mousedownShift\((-?\d+),(-?\d+)\)/).to_a.map(&:to_i)
      rel_x, rel_y = drawn_to_rel(drawx, drawy)

      @player.place_ladder(rel_x, rel_y)
    end
  end

  # This should be somewhere else
  def drawn_to_map(drawn_x, drawn_y)
    [drawn_x - VIS_RANGE + @player.x, drawn_y - VIS_RANGE + @player.y]
  end
  def drawn_to_rel(drawn_x, drawn_y)
    [drawn_x - VIS_RANGE, drawn_y - VIS_RANGE]
  end
  def map_to_drawn(map_x, map_y)
    [map_x + VIS_RANGE - @player.x, map_y + VIS_RANGE - @player.y]
  end
  def map_to_rel(map_x, map_y)
    [map_x - @player.x, map_y - @player.y]
  end
end
