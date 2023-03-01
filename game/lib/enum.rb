module Enum
  def enum(hash)
    hash.each do |key, vals|
      # Allows $player.mode to be called
      attr_accessor(key)
      # Player.modes
      define_singleton_method("#{key}s") { vals }
      # $player.modes
      define_method("#{key}s") { vals }
      # $player.mode
      define_method(key) { instance_variable_get("@#{key}") }
      # $player.mode = :mine
      define_method("#{key}=") { |new_mode| instance_variable_set("@#{key}", new_mode.to_sym) }
      # $player.mine? - bool for whether or not `mine` is the current mode
      # $player.mine! - Sets the mode to `mine`
      vals.each do |val|
        define_method("#{val}?") { instance_variable_get("@#{key}") == val.to_sym }
        define_method("#{val}!") { instance_variable_set("@#{key}", val.to_sym) }
      end
      # $player.next_mode -> Switches from left to right in `vals`
      define_method("next_#{key}") do
        old_idx = vals.index(instance_variable_get("@#{key}"))
        instance_variable_set("@#{key}", vals[(old_idx + 1) % vals.length])
      end
      # $player.prev_mode -> Switches from right to left in `vals`
      define_method("prev_#{key}") do
        old_idx = vals.index(instance_variable_get("@#{key}"))
        instance_variable_set("@#{key}", vals[(old_idx - 1) % vals.length])
      end
    end
  end
end
