# ruby play.rb 1234
# Start using a seed with the above ^^

require_relative "game/game"

# █⢎⡱⢾⡷⣏⣹⢕⢕⣿⣿⁅⁆⁙⁚⁜※∆∇░▒▓▞▗▘
# ＃＠～＊☰⬢
$messages = {}
$seed = ARGV[0]&.to_i || rand(10000)
srand($seed)

Draw.register_special_chars(2, "＃＠～＊☰⬢".chars)

$game = Game.new
Engine.start(
  game: $game,
  start: -> { $game.draw },
  tick: -> { $game.tick },
  # draw: -> { $game.draw }, # Only need this if there is motion outside of the player
  input: ->(key) { $game.input(key) },
  instant_input: ->(key) { $game.instant_input(key) },
  tick_time: 0.1,
)
