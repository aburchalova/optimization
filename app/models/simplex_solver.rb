class SimplexSolver
  include Solver

  # Given task without plan,
  # checks if constraints are compatible
  # and removes linear dependent constraints
  #
  def self.first_phase(task)
    #TODO: maybe add
  end

    # inverse matrix without inverter on step 1
    # potentials vector
    # estimates
    # if sufficient criteria is true, stop
    # else j0 = index of negative estimate
    # count z
    # if z <= 0, target function is unlimited
    # theta
    # minimal of theta and s - its index
    # nonbasis x(from old basis)
    # basis x (from old basis)
    # new basis
    # new A is different from old by the s-th column
    # invert new A
    # start again with new A and new basis

  def calculate_and_change_status
    return @status.not_a_plan! if !task.basis_plan?
    return @status.singular! if task.singular_basis_matrix?
    return @status.optimal! if task.sufficient_for_optimal?
    return @status.unlimited! if task.positive_z_index == nil # if z <= 0, target function is unlimited
    @status.step_completed!
  end
end
