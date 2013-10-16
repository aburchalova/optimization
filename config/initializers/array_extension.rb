class Array
  def find_all_with_indices(value)
    each_with_index.find_all { |a, i| a == value }
  end

  def zip_indices
    each_with_index.to_a
  end
end