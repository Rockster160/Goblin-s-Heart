require_relative "../engine/engine"
require_relative "../engine/infini_board"

Dir.glob(File.join("./game" + "/**/*.rb")).each do |file|
  require file
end

class Game
  attr_accessor :board, :player

  VIS_RANGE = 10

  def initialize
    $board = Board.create
    $player = Player.new
    $player.board = $board

    # draw_bowls
  end

  def draw_bowls
    render_offset = [0, -11]
    File.read("../bowls.txt").split("\n").each_with_index do |row, y|
      row.chars.each_with_index do |char, x|
        cell = case char
        when "B" then Stone.base
        when " " then Air.base
        when "~" then Water.base
        when "." then next
        end
        $board.set([render_offset[0]+x, render_offset[1]+y], cell)
      end
    end
  end

  def tick
    draw if [
      $player.tick,
      $board.tick
    ].any?
  end

  def draw
    minx = $player.x - VIS_RANGE
    maxx = $player.x + VIS_RANGE
    miny = $player.y - VIS_RANGE
    maxy = $player.y + VIS_RANGE

    glinting = []
    visible_board = $board.area(minx..maxx, miny..maxy)
    # Update which blocks are visible- once visible, blocks stay visible forever
    visible_board.each_with_index { |row, drawn_y| row.each_with_index { |block, drawn_x|
      next if block.visible? # Do nothing - block has already been seen

      map_x, map_y = drawn_to_map(drawn_x, drawn_y)
      if $board.exposed?(map_x, map_y)
        visible_board[drawn_y][drawn_x] = $board.set([map_x, map_y], block.class.base)
      elsif block.glintable? && $player.within_glint_range?(*map_to_rel(map_x, map_y))
        glinting.push([block.class.glint_char, [drawn_x, drawn_y]])
      end
    } }

    Draw.board(visible_board) do |pencil|
      pencil.bg = Palette.air
      pencil.paint($player.icon, [VIS_RANGE, VIS_RANGE], fg: Palette.player, bg: Palette.player_bg)

      glinting.each do |glint_char, glint_coord|
        pencil.paint(glint_char, glint_coord)
      end

      mode_ui_coord = [1, 1]
      pencil.write(mode_icon, mode_ui_coord, fg: Palette.player)
    end

    # TODO extract this into a better UI
    inven_counts = $player.inventory.group_by(&:item)
    inven_counts.each do |item, blocks|
      block = blocks.first
      puts("#{item}: #{blocks.count} \t #{block.render_name}")
    end

    print "Seed(#{$seed.to_s.rjust(4, "0")}) Player#{$player.coord} "
    puts "Drawn#{$mousecoord} Map#{drawn_to_map(*$mousecoord)}" if $mousecoord&.length == 2
    $messages.each { |k, msg| puts msg }
  end

  def mode_icon
    case $player.mode
    when :mine then "⸕"
    when :walk then "⬌"
    when :place then "⬢"
    when :menu then "-"
    else "?"
    end
  end

  def input(key)
    # TODO this is gnarly, needs to be converted to input controller
    case key
    when :a, :left  then $player.try_action(-1,  0) # if !$player.menu?
    when :d, :right then $player.try_action(+1,  0) # if !$player.menu?
    when :space     then $player.jump # if !$player.menu?
    when :w, :up    then $player.try_action( 0, -1) # if !$player.menu?
    when :s, :down  then $player.try_action( 0, +1) # if !$player.menu?
    when :e         then $player.interact
    when :q         then $player.next_mode
    when :Q         then $player.prev_mode
    when :p         then Engine.prepause; binding.pry; Engine.postpause
    else
      # return puts(key) # uncomment for debugging to see which events are being triggered
    end

    draw
  end

  def instant_input(key) # Triggers as soon as it happens
    case key
    when /mousedown\(/
      _, drawx, drawy = key.to_s.match(/mouse\w+\((-?\d+),(-?\d+)\)/).to_a.map(&:to_i)
      rel_x, rel_y = drawn_to_rel(drawx, drawy)

      $player.try_mine(rel_x, rel_y)
    when /mousedownShift\(/
      _, drawx, drawy = key.to_s.match(/mouse\w+\((-?\d+),(-?\d+)\)/).to_a.map(&:to_i)
      rel_x, rel_y = drawn_to_rel(drawx, drawy)

      $player.place_ladder(rel_x, rel_y)
    when /mousedownCmd\(/, /mousedragCmd\(/
      _, drawx, drawy = key.to_s.match(/mouse\w+\((-?\d+),(-?\d+)\)/).to_a.map(&:to_i)
      map_x, map_y = drawn_to_map(drawx, drawy)

      $board.set([map_x, map_y], Water.base)
    end
  end

  # TODO: This should be somewhere else
  def drawn_to_map(drawn_x, drawn_y)
    [drawn_x - VIS_RANGE + $player.x, drawn_y - VIS_RANGE + $player.y]
  end
  def drawn_to_rel(drawn_x, drawn_y)
    [drawn_x - VIS_RANGE, drawn_y - VIS_RANGE]
  end
  def map_to_drawn(map_x, map_y)
    [map_x + VIS_RANGE - $player.x, map_y + VIS_RANGE - $player.y]
  end
  def map_to_rel(map_x, map_y)
    [map_x - $player.x, map_y - $player.y]
  end
end
