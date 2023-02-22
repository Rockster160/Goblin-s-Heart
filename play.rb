require_relative "game/game"

# █⢎⡱⢾⡷⣏⣹⢕⢕⣿⣿⁅⁆⁙⁚⁜※∆∇░▒▓▞▗▘
# ＃＠～＊☰⬢
Draw.register_special_chars(2, "＃＠～＊☰⬢".chars)

game = Game.new
Engine.start(
  game: game,
  start: -> { game.draw },
  tick: -> { game.tick },
  # draw: -> { game.draw }, # Only need this if there is motion outside of the player
  input: ->(key) { game.input(key) },
  instant_input: ->(key) { game.instant_input(key) },
  tick_time: 0.1,
)
