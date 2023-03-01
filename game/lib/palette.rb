module Apollo
  module_function
  def blue = [
    "#172038",  # 0
    "#253a5e",  # 1
    "#3c5e8b",  # 2
    "#4f8fba",  # 3
    "#73bed3",  # 4
    "#a4dddb"   # 5
  ]
  def green = [
    "#19332d",  # 0
    "#25562e",  # 1
    "#468232",  # 2
    "#75a743",  # 3
    "#a8ca58",  # 4
    "#d0da91"   # 5
  ]
  def brown = [
    "#4d2b32",  # 0
    "#7a4841",  # 1
    "#ad7757",  # 2
    "#c09473",  # 3
    "#d7b594",  # 4
    "#e7d5b3"   # 5
  ]
  def orange = [
    "#341c27",  # 0
    "#602c2c",  # 1
    "#884b2b",  # 2
    "#be772b",  # 3
    "#de9e41",  # 4
    "#e8c170"   # 5
  ]
  def red = [
    "#241527",  # 0
    "#411d31",  # 1
    "#752438",  # 2
    "#a53030",  # 3
    "#cf573c",  # 4
    "#da863e"   # 5
  ]
  def purple = [
    "#1e1d39",  # 0
    "#402751",  # 1
    "#7a367b",  # 2
    "#a23e8c",  # 3
    "#c65197",  # 4
    "#df84a5"   # 5
  ]
  def neutral = [
    "#090a14",  # 0
    "#10141f",  # 1
    "#151d28",  # 2
    "#202e37",  # 3
    "#394a50",  # 4
    "#577277",  # 5
    "#819796",  # 6
    "#a8b5b2",  # 7
    "#c7cfcc",  # 8
    "#ebede9"   # 9
  ]
end


module Palette
  module_function
  def invisible = Apollo.neutral[0]
  def brown     = Apollo.orange[2]
  def stone     = Apollo.neutral[5]
  def dirt      = Apollo.orange[2]
  def sand      = Apollo.orange[5]
  def sand_dark = Apollo.red[5]
  def ore       = Apollo.neutral[8]
  def ore_glow  = Apollo.neutral[2]
  def air       = Apollo.blue[5]
  def cave_air  = Apollo.neutral[3]
  def player_bg = Apollo.green[4]
  def player    = Apollo.neutral[1]
  def water     = Apollo.blue[3]
end

# TODO tentative palette

module TentativePallete
  module_function
  def stone = {
    base: Apollo.neutral,
    fg: 5,
    # dark: { # not necessary, darken by one step (-1) for every color by default 
    #   fg: 4
    # }
  }
  def dirt = {
    base: Apollo.orange,
    fg: stone.fg,
    bg: 2,
    dark: {
      fg: stone.dark.fg,
      # bg: 1 # not necessary, as it is a step down from default bg
    }
  }
  def sand = {
    base: Apollo.orange,
    fg: Apollo.red[5],
    bg: 5
  }
  def ore = {
    base: Apollo.neutral,
    fg: 8,
    bg: stone.bg,
    glint: { # we can store glint colors here too, and if block mechanics support it, use it
      fg: 2
    }
  }
  def air = {
    base: Apollo.blue,
    fg: 5,
    dark: { # this is cave air
      fg: Apollo.neutral[3]
    }
  }
  def player = {
    base: Apollo.neutral,
    fg: 1,
    bg: Apollo.green[4]
  }
  def water = {
    base: Apollo.blue,
    fg: 3
  }
end
