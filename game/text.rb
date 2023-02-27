module Text
  module_function

  def snake(str)
    str.to_s
      .gsub(/([a-z])([A-Z])/, '\1_\2')
      .gsub(/\s+/, "_")
      .gsub(/[^a-zA-Z_]/, "")
      .downcase
  end

  def title(str)
    snake(str)
      .split(/_+/)
      .map(&:capitalize)
      .join(" ")
  end

  def pascal(str)
    title(str).split(/\s+/).join("")
  end
end
