class SimplexSolver
  STATUSES = {
    :initialized => 'initialized',
    :optimal => 'optimal',
    :singular => 'matrix is singular',
    :unlimited => 'unlimited',
    :step_completed => 'step completed',
    :incompatible => 'incompatible constraints'
  }

  END_STATUSES = STATUSES.slice(:singular, :unlimited, :optimal, :incompatible)

  attr_accessor :task, :status, :logging

  def initialize(task_with_plan)
    @initial_task = task_with_plan
    @task = task_with_plan
    @status = STATUSES[:initialized]
    @logging = false
    self
  end

  def self.simple_init(a, b, c, plan, basis)
    task1 = LinearTask.new(:a => a, :b => b, :c => c)
    x = BasisPlan.new(plan, basis)
    task_with_plan = LinearTaskWithBasis.new(task1, x)
    new(task_with_plan)
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
    if !task.basis_plan?
      @status = STATUSES[:incompatible]
    elsif task.singular_basis_matrix?
      @status = STATUSES[:singular]
    elsif task.sufficient_for_optimal? #sufficient for optimal
      @status = STATUSES[:optimal]
    elsif task.positive_z_index == nil # if z <= 0, target function is unlimited
      @status = STATUSES[:unlimited]
    else
      @status = STATUSES[:step_completed]
    end
    new_task = compose_new_task
    calculate_target_function_delta(new_task)
    log_stats
    set_new_task(new_task)
    self
  end

  def log_stats
    puts self if logging
  end

  def compose_new_task
    return task if finished?
    inverted_new_matrix = new_a_b_inv
    task.with(new_x, new_basis).tap do |t|
      t.inverted_basis_matrix = inverted_new_matrix
    end
  end

  def set_new_task(new_task)
    @task = new_task
  end

  def iterate
    step until finished?
  end

  def optimal?
    @status == STATUSES[:optimal]
  end

  def result
    iterate
    optimal? && task.x_ary || status
  end

  def new_x
    result = Array.new(task.n, 0)
    fill_basis_components(result)
    fill_non_basis_components(result)
    Matrix.new(result).transpose
  end

  def target_function_delta(new_task)
    new_task.target_function - task.target_function
  end

  def calculate_target_function_delta(new_task)
    @target_function_delta = new_task.target_function - task.target_function
  end

  def new_basis
    # puts "new basis: #{task.basis_indexes.dup.tap { |indices| indices[s] = new_basis_column }}"
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

  def new_a_b
    # puts "old basis matrix: \n#{task.a_b}\nnew basis: #{new_basis}\nnew basis matrix: #{task.a.cut(new_basis)}"
    task.a.cut(new_basis)
  end

  def new_a_b_inv
    new_a_b.inverse(task.a_b_inv, s)
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

  def initial_status
    return unless @status == STATUSES[:initialized]
%Q(
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #{task.task.to_s}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~)
  end

  def target_delta
    return unless @status == STATUSES[:step_completed]
    "Target function delta: #{@target_function_delta}\n"
  end

  def step_description
    return if @status == STATUSES[:initialized]
    task.to_s
  end

  def to_s
    %Q(
--------SIMPLEX SOLVER-----STATUS: #{status}----------------------
      #{initial_status}
      #{step_description}
      #{target_delta}
-------------------------------------------------------------)
  end
end
