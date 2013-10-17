class FirstPhaseSimplexAnalyzer

  attr_accessor :task, :status, :real_task_basis, :real_task, :result_task, :result_task_with_basis
  #real_task [LinearTask] is initially similar to the artificial task, but maybe with some constraints excluded.
  #real_task_basis contains working basis indices, initially - artificial task result basis indices
  #result_task_with_basis [LinearTaskWithBasis] contains task that's appropriate for simplex method
  #result_task [LinearTask] as task but with removed constraints

  alias_method :j_star_b, :real_task_basis

  # @param task [LinearTask]
  #
  def initialize(task)
    @task = task
    @result_task = task.dup
    @real_task = artificial_task
    @status = Statuses::SimplexFirstPhase.new
  end

  def analyze
    return status.incompatible! unless initial_task_has_plan?
    result_task_with_basis = LinearTaskWithBasis.new result_task, initial_task_basis_plan
  end

  def artificial_plan
    @initial_plan ||= BasisPlan.new initial_plan_matrix, initial_basis
  end

  def artificial_task
    @artificial_task ||= LinearTask.new(:a => new_a, :b => task.b, :c => new_c)
  end

  def new_task_with_basis
    @new_task_with_basis ||= LinearTaskWithBasis.new artificial_task, artificial_plan
  end
  alias :artificial_task_with_basis :new_task_with_basis

  def simplex_solver
    @solver ||= SimplexSolver.new(artificial_task_with_basis)
  end

  def artificial_task_result
    @result ||= simplex_solver.result #TODO: check if it's array or status
  end

  def initial_task_has_plan?
    result_fake_variables_sum == 0
  end

  def real_task_basis
    @real_task_basis || artificial_task_result_basis
  end

  # Getting result basis and setting it as a working one
  #
  def artificial_task_result_basis
    @art_result_basis ||= (@real_task_basis = simplex_solver.result_plan.basis_indexes)
  end

  def initial_task_basis_plan
    # if art. result basis contains art. indices, exclude it, else take result
     process_result_artificial_part until no_artifitial_intersect?
     status.got_task!
     BasisPlan.new result_real_part, real_task_basis
  end

  # Removes linear dependent constraints and artificial basis vars
  #
  def process_result_artificial_part
     # from real_task_basis we'll be excluding artificial vars
    jk = take_basis_artificial_var
    k = artificial_task_result_basis.index(jk)
    a = alphas(k, real_task_basis)
    j0 = non_zero_alpha_index(a)
    if j0 # plan is 'degenerage', it can go with multiple basises
      remove_artificial_variable(k, j0)
      status.removed_art_variable!
    else # linear dependent constraints
      remove_constraint(jk - task.n) # ??? task.n or real_task.n?
      @real_task_basis.delete(jk)
      status.linear_dependent!
    end
  end

  # @param working_basis [Array<Fixnum>] current basis
  # k is eye matrix column number that will be used for calculations
  #
  def alphas(k, working_basis)
    result = Array.new(new_width, 0)
    indices_to_check = real_non_basis_indices(working_basis)
    indices_to_check.map do |j|
      result[j] = alpha(j, k, working_basis_matrix(working_basis))
    end
  end

  # Returns nil if all alphas are zero and
  def non_zero_alpha_index(as)
    as.index { |a| a != 0 }
  end

  # jk will be removed and j0 added
  #
  def remove_artificial_variable(k, j0)
    @real_task_basis[k] = j0
  end

  # Remove i-th row from working matrix and b and
  # i: from 0 to m, m not included
  #
  def remove_constraint(i)
    real_task.a = real_task.a.remove_row(i)
    real_task.b = (Matrix.from_gsl real_task.b).remove_row(i)
    # TODO: refactor!!!!
    result_task.a = result_task.a.remove_row(i)
    result_task.b = (Matrix.from_gsl result_task.b).remove_row(i)
  end

  protected

  # aj = e'k * A_result_basis^(-1) * Aj
  # where A_result_basis is artificial result basis matrix
  # and Aj is initial, 'clean' task j-th column
  #
  # @param result_basis_matrix [Matrix] A_result_basis, basis matrix from previous step
  # initially it's equal to artificial task result basis matrix
  #
  def alpha(j, k, result_basis_matrix)
    result_basis_matrix.invert.transpose *
      Matrix.eye_row(:size => result_basis_matrix.size1, :index => k) *
      real_task.a.column(k) # ??? maybe should be modified as basis size will decrease
  end

  # working_basis is supposed to be real_task_basis
  # working_basis contains indices from 0 till n + m
  #
  def working_basis_matrix(working_basis)
    real_task.a.cut(working_basis)
  end
  alias_method :a_star_b, :working_basis_matrix

  # Initial task indices 0..n that are not in the artificial task result basis aka current_basis
  #
  def real_non_basis_indices(current_basis)
    real_indices - current_basis
  end

  # We have artificial task result and its basis.
  # Its basis contains artificial variables.
  # Take first index from these basis artificial variables.
  # If no intersection, returns nil.
  #
  def take_basis_artificial_var
    working_and_init_basis_intersect.shift
  end

  def working_and_init_basis_intersect
    puts "real_task_basis #{real_task_basis}"
    puts "initial_basis #{initial_basis}"
    real_task_basis & initial_basis
  end

  def no_artifitial_intersect?
    working_and_init_basis_intersect.empty?
  end

  def initial_basis
    @initial_basis ||= (task.n...new_width).to_a
  end

  def real_indices
    @real_indices ||= (0...task.n).to_a
  end
  alias_method :j, :real_indices

  def new_height
    @new_height ||= task.m
  end
  alias :new_basis_size :new_height

  def new_width
    @new_width ||= task.m + task.n
  end

  def initial_plan_ary
    Array.new(task.n, 0) + task.b.to_a.flatten
  end

  def initial_plan_matrix
    @initial_plan_matrix ||= Matrix.new_vector(initial_plan_ary).gsl_matrix
  end

  def new_a
    @new_a ||= widen_matrix
  end

  def widen_matrix
    eye = GSL::Matrix.eye(task.m)
    Matrix.from_gsl task.a.horzcat(eye)
  end

  def new_c
    @new_c ||= Matrix.new_vector(widened_c_ary)
  end

  def widened_c_ary
    Array.new(task.n, 0) + Array.new(task.m, -1)
  end

  def result_fake_variables_sum
    # take last new_basis_size vars
    artificial_task_result[-new_basis_size, new_basis_size].sum
  end

  def result_real_part
    artificial_task_result.values_at(*real_indices)
  end

end