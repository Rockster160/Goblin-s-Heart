module Calc
  module_function

  def distance(x1, y1, x2, y2)
    # √[(x₂ - x₁)² + (y₂ - y₁)²]
    Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
  end

  def rand_ratio(float) # 0-1
    rand < float
  end

  def rand_one_in(n)
    rand(n) == 0
  end
end
