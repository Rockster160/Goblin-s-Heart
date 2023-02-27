require_relative "block"

class Water < Block
  block_data char: "～", fg: Palette.water, solid: false, visible: true
  attr_accessor :level
  MAX_LEVEL = 8

  def self.levels = @levels

  def initialize(opts={})
    super(opts)
    @level = opts[:level] || MAX_LEVEL
  end
  # Must come after initialize - Air.base first so that 0 == Air
  # FIXME sticks air bg where it should be cave air
  @levels = [Air.base] + MAX_LEVEL.times.map { |t| Water.new(level: t+1, char: "▁▂▃▄▅▆▇█"[t]*2) }

  def tick(map_x, map_y)
    @did_move = false
    @map_x, @map_y = map_x, map_y

    fall
    spread unless @did_move

    @map_x, @map_y = nil, nil
    @did_move
  end

  def reloaded_level
    block = $board.at(@map_x, @map_y)
    return 0 unless block.is?(Water)

    block.level
  end

  def fall
    # Fall straight down
    absorb([@map_x, @map_y+1], @level)
    return if @did_move

    reload_level = reloaded_level

    # Fall left/right if there is any left
    left_block = $board.at(@map_x-1, @map_y+1)
    right_block = $board.at(@map_x+1, @map_y+1)
    left_open = left_block.air?|| left_block.is?(Water)
    right_open = right_block.air?|| right_block.is?(Water)

    spreadable = [left_open, right_open].count(true)
    return if spreadable <= 0

    split_a = reload_level / spreadable
    split_b = reload_level - split_a

    if left_open && !right_open
      absorb([@map_x-1, @map_y+1], split_a)
    elsif right_open && !left_open
      absorb([@map_x+1, @map_y+1], split_a)
    else # both open
      left, right = [split_a, split_b].shuffle
      absorb([@map_x-1, @map_y+1], left)
      absorb([@map_x+1, @map_y+1], right)
    end

    # Engine.prepause; $done || ($done ||= true) && binding.pry; Engine.postpause
  end

  def spread
    reload_level = reloaded_level
    return follow if reload_level <= 1

    left_block = $board.at(@map_x-1, @map_y)
    right_block = $board.at(@map_x+1, @map_y)
    left_open = left_block.air? || left_block.is?(Water)
    right_open = right_block.air? || right_block.is?(Water)

    spreadable = [true, left_open, right_open].count(true)
    return if spreadable <= 1

    spread_level = [].tap { |spread_blocks|
      spread_blocks << reload_level
      spread_blocks << left_block.level if left_block.is?(Water)
      spread_blocks << right_block.level if right_block.is?(Water)
    }.sum
    levels = spreadable.times.map {
      spread = spread_level / spreadable
      spreadable -= 1
      spread_level -= spread
      spread
    }
    levels.sort!
    # Use set instead of absorb because we already calculated levels
    set([@map_x, @map_y], levels.pop) # Deepest stays in the middle
    levels.shuffle!
    set([@map_x-1, @map_y], levels.pop) if left_open
    set([@map_x+1, @map_y], levels.pop) if right_open
    @did_move = true if left_block.air? || right_block.air?
  end

  def follow
    left_block_water = $board.at(@map_x-1, @map_y).is?(Water)
    right_block_water = $board.at(@map_x+1, @map_y).is?(Water)
    return if left_block_water || right_block_water

    [-2, +2].shuffle.each { |far|
      reload_level = reloaded_level
      next if reload_level < 1

      far_water = $board.at(@map_x+far, @map_y).is?(Water)
      absorb([@map_x+(far/2), @map_y], reload_level) if far_water
    }
  end

  def absorb(to_map_coord, give_level)
    reload_level = reloaded_level
    give_level = give_level.clamp(0, reload_level)
    this_level = reload_level - give_level
    return if give_level == 0

    spread_x, spread_y = *to_map_coord
    spread_to = $board.at(*to_map_coord)
    if spread_to.air?
      @did_move = true
    elsif spread_to.is?(Water)
      total = spread_to.level + give_level
      to_total = total.clamp(0, MAX_LEVEL)
      new_total = total - to_total
      this_level += new_total
      give_level = to_total

      @did_move = true if new_total == 0
    else
      return # No spreading because block is not air or water
    end

    set(to_map_coord, give_level)
    set([@map_x, @map_y], this_level)
  end

  def set(map_coord, set_level)
    $board.set(map_coord, Water.levels[set_level]) # 0 will be air
  end
end
Water.register_klass
# Engine.prepause; $done || ($done ||= true) && binding.pry; Engine.postpause
