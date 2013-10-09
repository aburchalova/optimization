class SimplexSolver
  STATUSES = {
    :initialized => 'initialized',
    :optimal => 'solved',
    :singular => 'matrix is singular',
    :unlimited => 'unlimited',
    :step_completed => 'step completed'
  }

  END_STATUSES = STATUSES.slice(:singular, :unlimited, :optimal)

  attr_accessor :task, :status, :logging

  def initialize(task_with_plan)
    raise ArgumentError, 'Given plan is not a basis plan' unless task_with_plan.basis_plan?
    @initial_task = task_with_plan
    @task = task_with_plan
    @status = STATUSES[:initialized]
    @logging = false
    self
  end

  def finished?
    END_STATUSES.values.include?(status)
  end

  def step
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

    if task.singular_basis_matrix?
      @status = STATUSES[:singular]
    elsif task.sufficient_for_optimal? #sufficient for optimal
      @status = STATUSES[:optimal]
    elsif task.positive_z_index == nil # if z <= 0, target function is unlimited
      @status = STATUSES[:unlimited]
    else
      @status = STATUSES[:step_completed]
    end
    puts self if logging
    @task = task.with(new_x, new_basis) if @status == STATUSES[:step_completed]
    self
  end

  # def set_step_end_status
  #   @status = @task.sufficient_for_optimal? ? STATUSES[:optimal] : STATUSES[:step_completed]
  #   @status = STATUSES[:unlimited] if task.positive_z_index == nil
  # end

  def first_step #TODO: add setting a_b_inv_new

  end

  def iterate
    step until finished?
  end

  def new_x
    result = Array.new(task.n, 0)
    fill_basis_components(result)
    fill_non_basis_components(result)
    Matrix.new(result).transpose
  end

  def new_basis
    puts "basis indexes - #{task.basis_indexes}"
    puts "making basis_indexes[#{s}] = #{new_basis_column}, i.e. instead of #{task.basis_indexes[s]}"
    task.basis_indexes.dup.tap { |indices| indices[s] = new_basis_column }
  end

  # Index of minimal theta. New basis matrix will be different by column #s
  def s
    task.min_theta_index
  end

  def new_nonbasis_column
    task.basis_indexes[s]
  end

  def new_basis_column
    task.j0
  end

  def new_a_b_inv
    task.a_b.inverse(task.a_b_inv, s)
  end

  def fill_basis_components(result)
    # for each i in basis indexes newx[j_i] = x[j_i] - min_theta * z[i]
    task.z_ary.each_with_index do |zi, i|
      x_idx = task.basis_indexes[i]
      result[x_idx] = task.x_ary[x_idx] - task.min_theta * zi
    end
    result
  end

  def fill_non_basis_components(result)
    result[task.j0] = task.min_theta
    result
  end

  def to_s
    %Q(
      --------SIMPLEX SOLVER-----STATUS: #{status}---------
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      INITIAL TASK: #{task.task.to_s}
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #{task.to_s}
      ------------------------------------------------------
    )
  end
end
