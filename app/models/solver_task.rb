# Metaclass for LinearTask for simplex method and
# LinearTask for double simplex method
#
module SolverTask
  attr_accessor :task, :plan, :sign_restrictions
  attr_writer :inverted_basis_matrix
  delegate :m, :n, :a, :b, :c, :to => :task
  delegate :basis_indexes, :x_ary, :to => :plan

  def initialize(task, plan, sign_restrictions = nil)
    @task, @plan = task, plan
    @sign_restrictions = sign_restrictions || ->(x) { x.isnonneg? }
  end

  # plan_vect is array, makes matrix
  #
  def with(plan_vect, basis_indices)
    ::LinearTaskWithBasis.new(task, BasisPlan.new(plan_vect, basis_indices))
  end

  def basis_matrix
    @a_b ||= task.a.cut(plan.basis_indexes)
  end
  alias :a_b :basis_matrix

  def singular_basis_matrix?
    a_b.det.zero?
  end

  def inverted_basis_matrix
    @inverted_basis_matrix ||= a_b.invert
  end

  # Ability to pass already calculated matrix for optimization
  #
  def inverted_basis_matrix=(matrix)
    @inverted_basis_matrix ||= matrix
  end
  alias :a_b_inv :inverted_basis_matrix
  alias :a_b_inv= :inverted_basis_matrix=

  def nonbasis_matrix
    @a_n ||= task.a.cut(plan.nonbasis_indexes)
  end
  alias :a_n :nonbasis_matrix

  def basis_det
    @basis_det ||= basis_matrix.det
  end
  alias :a_b_det :basis_det

  def sufficient_for_optimal?
    !singular_basis_matrix?
  end
end
