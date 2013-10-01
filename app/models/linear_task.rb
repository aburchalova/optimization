# Class for solving linear programming tasks
# in canonical form
# e.g. maximizing c' * x
# when A * x = b
# and x >= 0

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

  def target_function(x)
    c.transpose * x
  end
end