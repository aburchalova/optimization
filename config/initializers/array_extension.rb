class Array
  def find_all_with_indices(value = nil, &block)
    comparator = value ? proc { |a, i| a == value } : proc { |a, i| block.call(a) }
    each_with_index.find_all(&comparator)
  end

  def zip_indices
    each_with_index.to_a
  end

  # Takes a block which will be evaluated for each item
  # Returns array of indices of items that matched the condition
  #
  def find_all_indices
    each_with_index.find_all { |i, _| yield(i) }.map &:last
  end
end
