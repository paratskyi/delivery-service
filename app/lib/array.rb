class Array
  def find_by_value(value)
    detect { |element| element == value }
  end
end
