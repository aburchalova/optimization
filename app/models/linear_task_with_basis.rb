require 'delegate'

#
# +task+ is LinearTask
# +plan+ is BasisPlan
#
class LinearTaskWithBasis
  include SolverTask


  # TODO: add memoization?
  #
  # @param x [Matrix] solution vector
  # @return [true, false] if x is task plan
  #
  def plan?
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

  def c_b
    @c_b ||= task.c.cut_rows(plan.basis_indexes)
  end

  def c_n
    @c_n ||= task.c.cut_rows(plan.nonbasis_indexes)
  end

  def target_function
    (task.c_string * plan.x).get(0)
  end

  # M vector
  #
  def potential_vector
    @potential_vector ||= potential_string.transpose
  end

  def potential_string
    @potential_string ||= c_b.transpose * a_b_inv
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

  def negative_estimate_index
    estimates_ary.index { |i| i < 0 }
    # Blend rule: taking minimal ji. ji is a part of non-basis indices so that estimates[ji] < 0
    # est_and_basis = estimates.zip(basis) # last - unique. first - not unique
    # negative_estimates = est_and_basis.select { |e_and_b| e_and_b.first < 0 }
    # blend_estimate_and_index = negative_estimates.min_by { |est_and_b| est_and_b.last }
    # result = est_and_basis.index(blend_estimate_and_index)
  end
  alias :j0 :negative_estimate_index

  # @param new_x [Matrix] new plan
  #
  # doesn't work
  def target_function_delta(new_x)
    est_string = Matrix.new(estimates_ary)
    - (est_string * (new_x - plan.x)).get(0)
  end

  def calculate_z
    j = negative_estimate_index
    return if !j
    matrix_col = task.a.cut([j]).gsl_matrix
    inverted_basis_matrix * matrix_col
  end

  # returns nil if sufficient for optimal
  #
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

  def calculate_min_theta_index
    # Blend rule: taking min theta with its index s so that basis_indexes[s] is min
    # e.g. theta = [inf, 4, 4], Jb = [9, 8, 7]
    basis_idx_for_min_thetas = basis_indexes.zip_indices.values_at(*min_thetas_indices) # => [[8, 1], [7, 2]]
    basis_idx_for_min_thetas.min_by(&:first).last # => 2
  end

  def min_theta
    theta[min_theta_index]
  end

  def min_theta_index
    @min_theta_index ||= calculate_min_theta_index
  end

  def min_thetas_indices
    # e.g. theta = [inf, 4, 4], Jb = [9, 8, 7]
    min_thetas = theta.find_all_with_indices(theta.min) # => [[4, 1], [4, 2]] min theta is 4 and it's on 1th and 2nd pos
    min_thetas.map(&:last) # => [1, 2]
  end
  private :min_thetas_indices

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
    res += description_for_non_optimal unless singular_basis_matrix? || sufficient_for_optimal?
    res
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

  def clone
    LinearTaskWithBasis.new(task.clone, plan.clone)
  end
end
