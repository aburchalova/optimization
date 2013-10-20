require 'delegate'

# x should be gsl VERTICAL matrix
# 
class BasisPlan < Struct.new(:x, :basis_indexes)
  def method_missing(method, *args)
    return x.send(method, *args) if x.respond_to?(method)
    super
  end

  def respond_to_missing?(method_name, include_private = false)
    x.respond_to?(method_name) || super
  end

  def x_ary
    x.to_a.flatten
  end

  # def initialize(hash)
  #   # check for basis_indexes correctness: is included in x length range
  #   super(*hash.values_at(*self.class.members))
  # end

  def nonbasis_indexes
    (0...x_ary.length).to_a - basis_indexes
  end

  # array of basis x components
  #
  def x_b
    # GSL::Matrix[x.to_a.values_at(*basis_indexes)]
    # x.cut(basis_indexes)
    x_ary.values_at(*basis_indexes)
  end

  # array of non-basis x components
  #
  def x_n
    x_ary - x_b
    # x.cut(basis_indexes)
  end

  def zero_x_n?
    x_n.all? &:zero?
  end

  def positive_x_b?
    x_b.all? { |item| item > 0 }#&0.method(:<) # positive
  end

  def clone
    BasisPlan.new(:x => x.clone, :basis_indexes => basis_indexes.dup)
  end
end
