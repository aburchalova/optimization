# AS I WILL FORGET IT IN A WEEK - TERMINOLOGY
# We have some linear task to solve with simplex method,
# but don't have initial basis plan to begin with.
# So we compose an ARTIFICIAL task, to which finding a
# initial basis plan is pure bounty,
# find it, solve it, and get #artificial_task_result and #artificial_task_result_basis.
# Then we can see if #initial_task_has_plan.
# If it has, everything is ok.
# So we get a working task (a, b and c) which we call #real_task -
# because it's the task that will at the end become the fucking fancy task
# that will do for a simplex solver.
# And of course #real_task_basis - from which we'll exclude or exchange variables.
# The problem is when

class FirstPhaseSimplexAnalyzer

  attr_accessor :task, :status, :logging,
    :real_task_basis, :real_task,
    :result_task, :result_task_with_basis, :basis_plan, #basis_plan can be used in simplex method
    :widened_optimal_plan

  #real_task [LinearTask] is initially similar to the artificial task, but maybe with some constraints excluded.
  #real_task_basis contains working basis indices, initially - artificial task result basis indices
  #result_task_with_basis [Tasks::Simplex] contains task that's appropriate for simplex method
  #result_task [LinearTask] as task but with removed constraints

  # @param task [LinearTask]
  #
  def initialize(task)
    @task = task
    @logging = false
    @status = Statuses::SimplexFirstPhase.new
  end

  def analyze
    solve_artificial_task
    if !status.finished?
      prepare_working_task
      try_compose_real_task_with_plan
    end
    puts self if logging
  end

  def solve_artificial_task
    @widened_optimal_plan = artificial_tasker.solve.data
    status.inner_error! unless widened_optimal_plan # if no result, data = nil
    widened_optimal_plan
  end

  def try_compose_real_task_with_plan
    if compatible_constraints?
      @basis_plan = find_initial_task_basis_plan
      @result_task_with_basis = Tasks::Simplex.new(result_task, basis_plan, invert_negative: true)
    else
      status.incompatible!
    end
  end

  def compatible_constraints?
    # take last task.m vars
    fake_vars_count = task.m
    fake_vars_sum = widened_optimal_plan.x_ary[-fake_vars_count, fake_vars_count].sum
    fake_vars_sum == 0
  end

  ############## Artificial task stuff ####################
  def artificial_tasker
    @artificial_tasker ||= ArtificialTasker.new(task)
  end

  # Getting result basis and setting it as a working one
  #
  def widened_optimal_plan_basis #TODO: check for nil or for inner error
    @art_result_basis ||= widened_optimal_plan.basis_indexes
  end

  def artificial_indices
    artificial_tasker.artificial_indices
  end

  def prepare_working_task
    @real_task_basis = widened_optimal_plan.basis_indexes
    @real_task = artificial_tasker.task #get it from tasker?
    @result_task = task.invert_neg_rows
  end
  #########################################################

  ############## Removing art vars stuff ####################
  def find_initial_task_basis_plan
    kill_one_artificial until status.got_task?
    BasisPlan.new optimal_plan_real_part, real_task_basis
  end

  def kill_one_artificial
    ArtificialVariableRemover.new(self).try_remove
    puts self if logging
  end

  def optimal_plan_real_part
    vector = Matrix.from_gsl widened_optimal_plan.x
    vector.cut_rows(real_indices)
  end

  def real_indices
    (0...task.n).to_a
  end
  #########################################################

  def to_s
    res = "-----------------------\nFirst phase simplex analyzer STATUS = #{status}"
    res += status.finished? ? result_s : working_s
  end

  def working_s
    %Q(
      Working task: #{real_task}
      Working basis: #{real_task_basis}
    )
  end

  def result_s
    %Q(
      Result task: #{result_task}
      Result basis: #{real_task_basis}
      Result plan: #{basis_plan}
    )
  end
end
