class TransportProblem::Data
  attr_accessor :a, :b, :c

  # a [Array] suppliers (size m)
  # b [Array] consumers (size n)
  # c [Matrix, GSL::Matrix] cost      (size m * n)
  #
  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c
  end

  def m
    a.length
  end

  def n
    b.length
  end

  # Cell that has minimal c in it
  #
  # @return [Matrices::Cell]
  def min_c_cell
    @min_c_cell ||= Matrices::Cell.new(c.min_index)
  end

  # Corresponding a and b for the cell that has minimal c
  #
  # @return [Array] [a, b]
  #
  def a_b_for_min_c
    a = a[min_c_cell.row]
    b = b[min_c_cell.column]
    [a, b]
  end

  def remove_row!(i)
    a.delete_at(i)
    with!(:c => c.remove_row(i))
  end

  def remove_column!(i)
    b.delete_at(i)
    with!(:c => c.remove_column(i))
  end

  # New data with given changes
  #
  # @param options [Hash] :a => ..., :b => ..., :c => ...
  #
  def with(options)
    TransportProblem::Data.new(
      options[:a] || a.try(:clone),
      options[:b] || b.try(:clone),
      options[:c] || c.try(:clone)
    )
  end

  def with!(options)
    @a = options[:a] || a
    @b = options[:b] || b
    @c = options[:c] || c
    self
  end

  # Removes rows where a == 0 and cols
  # where b == 0.
  #
  def chomp!
    a.find_all_indices(&:zero?).each { |i| remove_row!(i) } if a
    b.find_all_indices(&:zero?).each { |i| remove_column!(i) } if b
    self
  end

  def chomp
    clone.chomp!
  end

  def compatible?
    a.all?(&:nonneg?) && b.all?(&:nonneg?)
  end

  def clone
    with({})
  end
end
