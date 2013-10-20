# analyzer is first phase simplex analyzer
#
class ArtificialVariableRemover < Struct.new(:analyzer)
  delegate  :real_task_basis, :artificial_indices, :status,
            :real_task, :real_indices, :result_task,
            :to => :analyzer

  # Removes linear dependent constraint or artificial basis var
  #
  def try_remove
    # from real_task_basis we'll be excluding artificial vars
    jk = first_art_var_from_basis
    jk ? remove_art_var_or_constraint(jk) : status.got_task!
  end

  protected

  def first_art_var_from_basis
    ArtificialBasisPicker.new(
      :basis => real_task_basis, :artificial_indices => artificial_indices
    ).take
  end

  def real_var_basis_candidate(jk)
    PlanDegeneracyAnalyzer.new(
      :working_task_matrix => real_task.a,
      :basis => real_task_basis, :real_indices => real_indices, :jk => jk
    ).real_basis_candidate
  end

  def remove_art_var_or_constraint(jk)
    j0 = real_var_basis_candidate(jk)
    add_to_basis_or_remove_constraint(jk, j0)
  end

  # jk is artificial var that we'll try to remove from basis
  # j0 is real var that we'll try to add to basis
  #
  def add_to_basis_or_remove_constraint(jk, j0)
    if can_add_to_basis?(j0)
      remove_artificial_variable(jk, j0)
    else
      process_linear_dependent(jk)
    end
  end

  def can_add_to_basis?(j0)
    !!j0
  end

  # jk will be removed and j0 added
  #
  def remove_artificial_variable(jk, j0)
    k = real_task_basis.index(jk)
    real_task_basis[k] = j0
    status.removed_art_variable!
  end

  def process_linear_dependent(jk)
    LinearConstraintRemover.new(
      :real_task => real_task, :result_task => result_task,
      :real_task_basis => real_task_basis, :jk => jk
    ).remove
    status.linear_dependent!
  end
end