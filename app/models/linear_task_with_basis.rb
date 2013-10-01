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
  def plan?
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

  def nonbasis_matrix
    task.a.cut(plan.nonbasis_indexes)
  end

  def basis_det
    basis_matrix(plan).det
  end

  def target_function
    task.target_function(plan)
  end
end