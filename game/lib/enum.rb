module Enum
  def enum(hash)
    hash.each do |key, vals|
      attr_accessor(key)
      define_singleton_method("#{key}s") { vals }
      define_method("#{key}s") { vals }
      define_method(key) { instance_variable_get("@#{key}") }
      define_method("#{key}=") { |new_mode| instance_variable_set("@#{key}", new_mode.to_sym) }
      vals.each do |val|
        define_method("#{val}?") { instance_variable_get("@#{key}") == val.to_sym }
        define_method("#{val}!") { instance_variable_set("@#{key}", val.to_sym) }
      end
      define_method("next_#{key}") do
        old_idx = vals.index(instance_variable_get("@#{key}"))
        instance_variable_set("@#{key}", vals[(old_idx + 1) % vals.length])
      end
      define_method("prev_#{key}") do
        old_idx = vals.index(instance_variable_get("@#{key}"))
        instance_variable_set("@#{key}", vals[(old_idx - 1) % vals.length])
      end
    end
  end
end
