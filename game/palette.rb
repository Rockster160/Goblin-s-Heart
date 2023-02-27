module Apollo
  module_function
  def blue = [
    "#172038",
    "#253a5e",
    "#3c5e8b",
    "#4f8fba",
    "#73bed3",
    "#a4dddb"
  ]
  def green = [
    "#19332d",
    "#25562e",
    "#468232",
    "#75a743",
    "#a8ca58",
    "#d0da91"
  ]
  def brown = [
    "#4d2b32",
    "#7a4841",
    "#ad7757",
    "#c09473",
    "#d7b594",
    "#e7d5b3"
  ]
  def orange = [
    "#341c27",
    "#602c2c",
    "#884b2b",
    "#be772b",
    "#de9e41",
    "#e8c170"
  ]
  def red = [
    "#241527",
    "#411d31",
    "#752438",
    "#a53030",
    "#cf573c",
    "#da863e"
  ]
  def purple = [
    "#1e1d39",
    "#402751",
    "#7a367b",
    "#a23e8c",
    "#c65197",
    "#df84a5"
  ]
  def neutral = [
    "#090a14",
    "#10141f",
    "#151d28",
    "#202e37",
    "#394a50",
    "#577277",
    "#819796",
    "#a8b5b2",
    "#c7cfcc",
    "#ebede9"
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
end

# TODO tentative palette

# module Pallete
#   module_function
#   def stone = {
#     base: Apollo.neutral,
#     light: 5,
#     dark: 6,
#   }
# end

