class DoubleSimplexSolver
  include Solver

  def calculate_and_change_status
    return @status.not_a_plan! if !task.basis_plan?
    return @status.singular! if task.singular_basis_matrix?
    return @status.optimal! if task.sufficient_for_optimal?
    return @status.unlimited! if task.positive_z_index == nil # if z <= 0, target function is unlimited
    @status.step_completed!
  end
end