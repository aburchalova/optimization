require 'delegate'

#
# +task+ is LinearTask
# +plan+ is BasisPlan
#
class LinearTaskWithBasis
  attr_accessor :task, :plan
  attr_writer :inverted_basis_matrix
  delegate :m, :n, :to => :task
  delegate :basis_indexes, :x_ary, :to => :plan

  def initialize(task, plan)
    @task, @plan = task, plan
  end

  # plan_vect is array, makes matrix
  # 
  def with(plan_vect, basis_indices)
    ::LinearTaskWithBasis.new(task, BasisPlan.new(plan_vect, basis_indices))
  end

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
    return sufficient_for_optimal? if nonsingular_plan?
    sufficient_for_optimal? ? true : nil
  end

  def sufficient_for_optimal?
    !singular_basis_matrix? && estimates_ary.all? { |i| i >= 0 }
  end

  # def target_function_unlimited?
  #   !sufficient_for_optimal? && nonsingular_plan?
  # end

  # def neccesary
  def basis_matrix
    @a_b ||= task.a.cut(plan.basis_indexes)
  end
  alias :a_b :basis_matrix

  def singular_basis_matrix?
    a_b.det.zero?
  end

  def inverted_basis_matrix #TODO: add ability to pass inverted?
    @inverted_basis_matrix ||= a_b.invert 
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

  def c_b
    @c_b ||= task.c.cut(plan.basis_indexes)
  end

  def c_n
    @c_n ||= task.c.cut(plan.nonbasis_indexes)
  end

  def target_function
    task.target_function(plan)
  end

  def potential_vector
    @potential_vector ||= potential_string.transpose
  end

  def potential_string
    @potential_string ||= c_b * a_b_inv
  end

  def potential_ary
    @potential_ary ||= @potential_string.to_a.flatten
  end

  def estimates_ary
    @estimates_ary ||= calculate_estimates_ary
  end

  def calculate_estimates_ary
    result = Array.new(plan.x_ary.length, 0)
    plan.nonbasis_indexes.each do |index|
      matrix_col = task.a.cut([index]).gsl_matrix # O_o because get_col throws some fucking error
      result[index] = (potential_string * matrix_col).get(0) - task.c.get(index)
      # puts "result[#{index}] = (#{potential_string} * #{matrix_col}).get(0) - #{task.c.get(index)} = #{result[index]}"
    end
    # puts "estimates : #{result}"
    result
  end

  def estimates_n
    estimates_ary.values_at(*plan.nonbasis_indexes)
  end

  def estimates_n_transpose
    Matrix.new(estimates_n).transpose
  end

  def negative_estimate_index
    estimates_ary.index { |i| i < 0 }
  end
  alias :j0 :negative_estimate_index

  def target_function_delta
    - (estimates_n * plan.x_n).get(0)
  end

  def calculate_z
    j = negative_estimate_index
    return if !j #TODO: use matrix inverter
    matrix_col = task.a.cut([j]).gsl_matrix
    inverted_basis_matrix * matrix_col
  end

  # returns nil if sufficient for optimal
  def z
    @z ||= calculate_z
  end

  def z_ary
    @z_ary ||= z.to_a.flatten
  end

  # returns nil if no positive item
  #
  def positive_z_index
    z_ary.index { |i| i > 0 }
  end

  def negative_z?
    positive_z_index == nil
  end

  def theta
    @theta ||= calculate_theta
  end

  # on the indices of negative z items == +infinity, else x[ji] / zi
  def calculate_theta
    result = Array.new(z_ary.length, Float::INFINITY)
    # puts "Jb = {#{plan.basis_indexes.join(',')}}"
    z_ary.each_with_index do |item, idx|
      # puts "theta[#{idx}] = x[j#{idx}] / z[#{idx}] = x[#{plan.basis_indexes[idx]}] / #{item} = #{plan.get(plan.basis_indexes[idx])} / #{item}"
      result[idx] = plan.get(plan.basis_indexes[idx]) / item if item > 0
    end
    # puts "theta result = #{result}"
    result
  end

  def min_theta_with_index
    # min returns [item, its index]
    @min_theta_index ||= theta.each_with_index.min
  end

  def min_theta
    min_theta_with_index.first
  end

  def min_theta_index
    min_theta_with_index.last
  end

  def description
    %Q(
  Basis matrix:
  #{a_b}

  Current x:
  #{x_ary}

  Basis indices:
  { #{basis_indexes.join(',')} }
  )
  end

  def description_for_non_singular
    %Q(
  Potentials string:
  #{potential_string}

  Estimates:
  #{estimates_ary}

  Non-basis estimates:
  #{estimates_n}

  j0 (negative estimate index):
  #{j0}
    )    
  end

  def to_s
    res = description
    res += description_for_non_singular unless singular_basis_matrix?
    res += description_for_non_optimal if !singular_basis_matrix? && !sufficient_for_optimal? 
  end

  def description_for_non_optimal
    %Q(
  Calculated z [ Ab^(-1) * A[j0] ]
  #{z}

  Theta:
  #{theta}

  Minimal theta:
  #{min_theta}

  Minimal theta index:
  #{min_theta_index}
    )
  end
end