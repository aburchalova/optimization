# Class for solving linear programming tasks
# in canonical form
# e.g. maximizing c' * x
# when A * x = b
# and x >= 0
# A is matrix, b and c - vectors
#
class LinearTask < Struct.new(:a, :b, :c)

  def initialize(hash)
    super(*hash.values_at(*self.class.members))
  end

  # Basis size, restrictions count
  #
  def m
    a.size1
  end

  # Variables count
  #
  def n
    a.size2
  end

  def c_string
    @c_string ||= c.transpose
  end

  def b_ary
    b.to_a.flatten
  end

  def c_ary
    c.to_a.flatten
  end

  def to_s
    %Q(
      A = #{m} by #{n} matrix
      #{a.to_s}

      b =
      #{b.to_s}

      c =
      #{c.to_s}
    )
  end

  def clone
    LinearTask.new(:a => a.try(:clone), :b => b.try(:clone), :c => c.try(:clone))
  end

  # Changes signs of all items in A and b i'th row
  #
  # @return [LinearTask] new task (old if nothing was modified)
  #
  def invert_neg_rows
    return self if b.isnonneg?
    result = clone
    b_ary.find_all_indices(&:neg?).each { |idx| neg_row(idx) }
    result
  end

  def neg_row(idx)
    a.neg_row(idx)
    Matrix.neg(b, idx, 0) # because b is a vector - has only 0th col
  end
end
