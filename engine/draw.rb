require_relative "./colorize"

class Pencil
  attr_accessor :fg, :bg, :sprites, :objects, :written

  def initialize
    @fg = :grey
    @bg = :black
    @sprites ||= {}
    @objects ||= {}
    @written ||= {}
  end

  def foreground(color)
    @fg = color
  end

  def background(color)
    @bg = color
  end

  # Change all instances of old_str into new_str and color it
  def replace(old_str, new_str, fg: nil, bg: nil)
    str = Draw.draw(new_str)
    str = Colorize.color(bg, str, :bg) if bg
    str = Colorize.color(fg, str, :fg) if fg
    @sprites[old_str.to_s] = str
  end

  def recolor(raw_str, fg: nil, bg: nil)
    str = Draw.draw(raw_str)
    str = Colorize.color(bg, str, :bg) if bg
    str = Colorize.color(fg, str, :fg) if fg
    @sprites[raw_str.to_s] = str
  end

  # Place char at coords
  def paint(str, coord, fg: nil, bg: nil)
    str = Draw.draw(str)
    str = Colorize.color(bg, str, :bg) if bg
    str = Colorize.color(fg, str, :fg) if fg
    @objects[coord.to_s] = str
  end

  # Write chars at coord
  def write(str, coord, fg: nil, bg: nil)
    str = Colorize.color(bg, str, :bg) if bg
    str = Colorize.color(fg, str, :fg) if fg
    @written[coord.to_s] = str
  end
end

$special_chars = {} # init global var
module Draw
  module_function

  BOX_CHARS = {
    tl: "┌",
    tm: "┬",
    tr: "┐",
    lm: "├",
    hz: "─",
    md: "┼",
    vt: "│",
    rm: "┤",
    bl: "└",
    bm: "┴",
    br: "┘",
  }

  def register_special_chars(width, *chars)
    chars.flatten.each do |char|
      $special_chars[char] = width
    end
  end
  def cell_width=(new_width); $cell_width = new_width; end
  def cell_width; $cell_width ||= 2; end
  def origin=(new_o); $board_origin = *new_o; end
  def origin; $board_origin ||= [0, 0]; end

  def offset_cell(x, y)
    ox, oy = Draw.origin
    [(x / Draw.cell_width.to_f).floor-ox, y-oy]
  end

  def clear_code
    "\e[K"
  end

  def clear_rest_screen
    print "\e[0J"
  end

  def clear_rest_line
    print(clear_code) || clear_code
  end
  def clr
    clear_rest_line
  end
  def cls
    system "clear" or system "cls"
    nil
  end

  def moveto(x, y)
    # +1 because term expects [1,1] origin
    print("\e[#{y+1};#{(x*cell_width)+1}f") || true
  end

  def newline
    "#{clear_code}\n\r"
  end

  def drawat(coord, text)
    moveto(*coord)
    print draw(text)
  end

  def align(str, width, padstr=" ", dir: :center)
    padwidth = (width - length(str)) / padstr.length
    case dir
    when :left # ljust
      "#{str}#{padstr*padwidth}"
    when :right # rjust
      "#{padstr*padwidth}#{str}"
    when :center
      rchars = (padwidth/2).round
      lchars = padwidth - rchars
      "#{padstr*lchars}#{str}#{padstr*rchars}"
    end
  end

  def unformat(str)
    str.to_s.gsub(/\e\[[\d\?;]*[a-zA-Z]/, "")
  end

  def length(str)
    unformat(str).chars.filter_map { |c| c.to_s.match?(/\p{Emoji_Presentation}/iu) ? 2 : 1 }.sum
  end

  def format(text, length)
    width = length || cell_width
    unformatted = unformat(text.to_s)
    return text.to_s.ljust(width, " ") if unformatted.length == 0

    char_width = 2 if text.to_s.match?(/\p{Emoji_Presentation}/iu)
    $special_chars[text]&.then { |force_width| char_width = force_width }
    ex_spaces = width - (char_width || unformatted.length)

    text.to_s.gsub(unformatted, unformatted+(" "*ex_spaces))
  end

  def draw(text, opts={})
    format(text, opts[:width] || cell_width)
  end

  def draw_borders(board_arr, opts={})
    splotch = opts[:splotch] || ->(str) { Colorize.grey(str) }
    px, py = opts[:padding] || [0, 0]
    ox, oy = Draw.origin
    sides = opts[:sides] == :all ? [:left, :up, :right, :down] : (opts[:sides] || [:right, :down])

    width = board_arr.first.length
    height = board_arr.length
    alpha = ("A".."Z").to_a

    height.times { |y|
      drawat([ox+width+px, y+oy], splotch.call(y+1)) if sides.include?(:right)
      drawat([ox-1-px, y+oy], splotch.call(y+1)) if sides.include?(:left)
    }
    width.times { |x|
      drawat([ox+x, height+oy+py], splotch.call(alpha[x])) if sides.include?(:down)
      drawat([ox+x, oy-1-py], splotch.call(alpha[x])) if sides.include?(:up)
    }
    moveto(0, height+1+oy+py)
    puts
  end

  def board(...)
    draw_board(...)
  end
  def draw_board(board_arr, opts={}, &block)
    return $should_redraw = true if $drawing # Prevent calling draw multiple times causing overflow
    $should_redraw = false
    $drawing = true
    Draw.origin = opts[:origin] if opts[:origin]
    ox, oy = Draw.origin
    # Move cursor to end of board so that the board/pencil block can print
    print Colorize.reset_code
    moveto(0, board_arr.length+oy)
    pencil = Pencil.new
    block&.call(pencil)
    bg = Colorize.color(pencil.bg, nil, :bg)
    fg = Colorize.color(pencil.fg, nil, :fg)
    moveto(ox, oy)
    board_arr.each_with_index { |row, y|
      drawat([ox, oy+y], "#{fg}#{bg}")
      row.each_with_index { |cell, x|
        if pencil.written[[x, y].to_s]
          text = pencil.written[[x, y].to_s]
          print draw(cell.to_s)
          drawat([x, y], text)
        elsif pencil.objects[[x, y].to_s]
          print pencil.objects[[x, y].to_s]
        elsif pencil.sprites[cell.to_s]
          print pencil.sprites[cell.to_s]
        else
          print draw(cell.to_s)
        end
        print "#{fg}#{bg}"
      }
    }
    moveto(0, board_arr.length+oy)
    print Colorize.reset_code
    clear_rest_screen
    draw_board(board_arr, opts, &block) if $should_redraw
    $drawing = false
  end
end

def puts(*args)
  print(*args)
  print "#{Draw.clr}#{Draw.newline}"
end
