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
    # because right-side arg can only be gsl matrix
    task.a * plan.x == task.b &&
      plan.x.isnonneg?
  end

  # number of basis indexes = equations number
  # non-basis components == 0,
  # basis matrix det != 0
  #
  def basis_plan?
    plan? &&
      plan.basis_indexes.length == task.m &&
      basis_det != 0
  end

  def nonsingular_plan?
    basis_plan? &&
      plan.positive_x_b?
  end

  # basis plan is nonsingular => is optimal only if sufficient is true
  # basis plan is singular => is optimal if sufficient is true, if sufficient is false, may be optimal or not
  # returns nil if not sure
  # 
  def optimal_plan?
    basis_plan && 
  end

  def sufficient_for_optimal?

  end

  # def neccesary 
  def basis_matrix
    task.a.cut(plan.basis_indexes)
  end
  alias :a_b :basis_matrix

  def nonbasis_matrix
    task.a.cut(plan.nonbasis_indexes)
  end
  alias :a_n :nonbasis_matrix

  def basis_det
    basis_matrix.det
  end
  alias :a_b_det :basis_det

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
    potential_string.transpose
  end

  def potential_string
    c_b * a_b.transpose
  end

  def estimates_ary
    result = Array.new(plan.length, 0)
    plan.nonbasis_indexes.each do |index|
      matrix_col = task.a.cut([index]).gsl_matrix # O_o because get_col throws some fucking error
      result[index] = (potential_string * matrix_col).get(0) - task.c.get(index)
    end
    result
  end

  def estimates_n
    estimates_ary.values_at(*plan.nonbasis_indexes)
  end

  def estimates_n_transpose
    Matrix.new(estimates_n).transpose
  end

  def target_function_delta
    - (estimates_n * plan.x_n).get(0)
  end
end
