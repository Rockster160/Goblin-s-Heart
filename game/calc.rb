module Calc
  module_function

  def distance(x1, y1, x2, y2)
    # √[(x₂ - x₁)² + (y₂ - y₁)²]
    Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
  end

  def rand_ratio(float) # 0-1
    rand < float
  end

  def rand_percent(percent) # 0-100
    rand(100) < percent
  end

  def rand_one_in(n)
    rand(n) == 0
  end

  def rand_by_weight(keyvals)
    sum = keyvals.values.sum
    selected_idx = rand(0..sum)
    keyvals.each do |key, weight|
      return key if selected_idx <= weight
      selected_idx -= weight
    end
  end
end
