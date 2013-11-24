class TransportProblem::Data
  attr_accessor :a, :b, :c
  # attr_accessor :disabled_rows, :disabled_columns

  # a [Array] suppliers (size m)
  # b [Array] consumers (size n)
  # c [Matrix, GSL::Matrix] cost      (size m * n)
  #
  def initialize(a = nil, b = nil, c = nil)
    @a = a
    @b = b
    @c = c.respond_to?(:remove_row) ? c : Matrix.from_gsl(c) if c
  end

  # The same data after removing rows/columns
  # E.g., when finding first plan, some rows/columns are 'crossed-out':
  # they are taken out of the minimal item / north-west item search,
  # but the indices of the matrix should stay the same as before.
  #
  # def available_data
  #   @available_data ||= clone
  # end

  def m
    a.length
  end
  alias :rowcount :m

  def n
    b.length
  end
  alias :colcount :n

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
    a_val = a[min_c_cell.row]
    b_val = b[min_c_cell.column]
    [a_val, b_val]
  end

  def a_b_for(cell)
    [a[cell.row], b[cell.column]]
  end

  def empty?
    m == 0 || n == 0
  end

  # Removes from self
  #
  def remove_row!(i)
    a.delete_at(i)
    new_c = c.remove_row(i) unless a.empty?
    with!(:c => new_c) #if @available_data
  end

  # Removes from self
  #
  def remove_column!(i)
    b.delete_at(i)
    new_c = c.remove_column(i) unless b.empty?
    with!(:c => new_c)
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

  def valid_constraints?
    a.sum == b.sum && compatible?
  end

  # @return [Array<Array<Cell>>]
  def all_cells
    rowcount.times.map do |i|
      colcount.times.map { |j| Matrices::Cell.new([i, j]) }
    end
  end

  def flat_all_cells
    all_cells.inject(:+)
  end

  def to_s
    "a: #{a.to_a.to_s}\nb:#{b.to_s}\nc:#{c.to_s}"
  end
end
