#
# +task+ is LinearTask
# +plan+ is BasisPlan
#
class LinearTaskWithBasis < Struct.new(:task, :plan)
  # TODO: add memoization?
  #
  # @param x [Matrix] solution vector
  # @return [true, false] if x is task plan
  #
  def plan? # TODO: change code to work with plan not matrix but basis plan. add delegation
    task.a * plan == task.b &&
      plan.all { |item| item >= 0 }
  end

  # number of basis indexes = equations number
  # non-basis components == 0,
  # basis matrix det != 0
  #
  def basis_plan?
    plan? &&
      plan.length == m &&
      basis_det != 0
  end

  def nonsingular_plan?
    basis_plan? &&
      plan.positive_x_b?
  end

  def basis_matrix
    task.a.cut(plan.basis_indexes)
  end
  alias A_b basis_matrix

  def nonbasis_matrix
    task.a.cut(plan.nonbasis_indexes)
  end
  alias A_n nonbasis_matrix

  def basis_det
    basis_matrix(plan).det
  end
  alias A_b_det basis_det

  def c_b
    task.c.cut(plan.basis_indexes)
  end

  def c_n
    task.c.cut(plan.nonbasis_indexes)
  end

  def target_function
    task.target_function(plan)
  end

  def potential_vector

  end
end
