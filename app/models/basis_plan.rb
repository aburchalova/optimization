require 'delegate'

class BasisPlan < Struct.new(:x, :basis_indexes)
  delegate :length, :to => :x

  def initialize(hash)
    # check for basis_indexes correctness: is included in x length range
    super(*hash.values_at(*self.class.members))
  end

  def nonbasis_indexes
    (0...x.length) - basis_indexes
  end

  # array of basis x components
  # 
  def x_b
    x.values_at(*basis_indexes)
  end

  # array of non-basis x components
  # 
  def x_n
    x - x_b
  end

  def zero_x_n?
    x_n.all? &:zero?
  end

  def positive_x_b?
    x_b.all? &0.method(:<) # positive
  end
end