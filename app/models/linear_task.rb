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

  def m
    a.size1
  end

  def n
    a.size2
  end

  def target_function(x_matrix)
    (c * x_matrix).get(0)
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
end
