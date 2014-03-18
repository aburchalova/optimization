# Class for solving tasks
# c'x -> max
# Ax = b
# xj - integer, j in J = {0...n}
#
class Integer::Gomori
  attr_accessor :current_task, # Tasks::Simplex that's solved now
    :current_basis_plan, # BasisPlan -- matrix and basis indexes
    :current_target_function, # Target function on current_basis_plan
    :status,
    :new_linear_task, # task with added restrictions that will be solved on next step
    :logging

  # Shortcut for current matrix
  #
  def a
    current_task.task.a
  end

  # Current basis matrix
  #
  def a_b
    current_task.a.cut(current_basis_plan.basis_indexes)
  end

  # Current inverted basis matrix
  #
  def a_b_inv
    a_b.invert
  end

  # Composes a new instance of Gomori solver
  # @param task [LinearTask]
  #
  def initialize(task, options = { logging: false })
    @natural_indices = (0...task.a.size2).to_a # TODO: check if right size
    @new_linear_task = task
    @status = Statuses::Gomori.new
    @logging = options[:logging] || false
  end

  # Find initial basis for linear_task a compose a simplex task
  #
  def create_simplex_task(linear_task)
    Tasks::Simplex.new(linear_task, basis_for_task(linear_task), invert_negative: true)
  end

  # Solve
  #
  def iterate
    step until status.finished?
  end

  def step
    @current_task = create_simplex_task(new_linear_task)
    solve_current_task
    remove_artificial_var if has_artificial_var?
    check_optimality
    return if status.integer_solution?
    compose_cutting_plane
  end

  # Find basis with first phase of simplex method
  def basis_for_task(linear_task)
    analyzer = FirstPhaseSimplexAnalyzer.new(linear_task)
    analyzer.analyze
    return analyzer.basis_plan if analyzer.status.got_task?
    # incompatible constraints or inner error in first phase
    status.from_code!(analyzer.status.code)
    return nil
  end

  def solve_current_task
    log_current_task
    result_status = Solvers::Simplex.new(current_task).result
    status.from_code!(result_status.code) # set the status the same as simplex solver
    @current_basis_plan = result_status.data
    @current_target_function = calculate_current_target_function
    log_current_task_solved
  end

  def check_optimality
    return unless @current_basis_plan
    status.integer_solution! and log("Optimal") if integer_task.satisfies_integer?(@current_basis_plan)
  end

  # aj = y' * Aj, j - all indices, artificial and natural
  # y' = e'io * Ab^(-1)
  # i0 is an noninteger basis variable index
  #
  # beta = y' * b
  #
  # so, this is [a, beta] Array[Fixnum], size - all indices + 1, or A colcount + 1
  #
  # USAGE: *a, b = cutting_plane_values
  #
  # noticeable facts: a[i0] = 1, aj = 0 for j in Jb\io
  #
  def cutting_plane_values
    y = y_string
    log("y' = #{y}")
    alpha = (y * a.gsl_matrix).to_a.flatten # Array<Float>
    beta = (y * current_task.task.b).get(0)
    log("New restriction (whole values): a = #{alpha}, b = #{beta}")
    alpha + [beta] # a flat array
  end

  # Difference between cutting plane values and their integer part
  #
  def cutting_plane_fraction_values
    cutting_plane_values.map &:fractional_part
  end

  # Will be used for cutting plane
  #
  def y_string
    i = noninteger_natural_basis_idx_basis_pos
    ei = Matrix.eye_row(size: a.size1, index: i)
    log("ei = #{ei}")
    ei * a_b_inv
  end

  # jk - from 0 to A.colcount - 1, etc x1, x2... xn
  # so that x[jk] is in basis and is non integer
  #
  def noninteger_natural_basis_idx
    satisfying_vars_with_indices = current_basis_plan.x_ary.each_with_index.find_all do |value, idx|
      current_basis_plan.basis_indexes.include?(idx) && @natural_indices.include?(idx) && !value.int?
    end
    satisfying_vars_with_indices.first.last
  end

  # k from 0 to |Jb| - 1 -- position of jk in basis
  #
  def noninteger_natural_basis_idx_basis_pos
    jk = noninteger_natural_basis_idx
    k = current_basis_plan.basis_indexes.index(jk)
    log("Noninteger natural basis variable: #{jk}")
    log("Its position in basis: #{k}")
    k
  end

  # Create a new restriction and a new linear task with it
  #
  def compose_cutting_plane
    # add new last column -- 0 everywhere and 1 for the new row (last one)
    a_lines = a.to_a.map { |ary| ary + [0] }
    *new_line, new_b_item = cutting_plane_fraction_values.map { |val| -val }
    new_line << 1
    log("new restriction (fraction values): a = #{new_line}, b = #{new_b_item}")
    # if b < 0 negotiate all
    if new_b_item < 0
      new_line = new_line.map { |val| -val }
      new_b_item *= -1
      log("b < 0 => negotiated that row")
    end

    new_a_lines = a_lines + [new_line] # TODO: check if vars at basis indices will be 0
    new_b_lines = current_task.task.b.to_a + [[new_b_item]]
    new_c_lines = current_task.task.c.to_a + [[0]]
    new_b = Matrix.new(*new_b_lines).gsl_matrix # [[]] as it's a vector
    new_c = Matrix.new(*new_c_lines)
    @new_linear_task = LinearTask.new(a: Matrix.new(*new_a_lines), b: new_b, c: new_c)
  end

  # Removes artificial variables from result
  #
  def natural_result_ary
    current_basis_plan.x_ary.values_at(*@natural_indices)
  end

  # Artificial variable in basis -- it can be removed
  #
  def var_number_to_remove
    (current_basis_plan.basis_indexes - @natural_indices).first
  end

  # A corresponding restriction to variable number (that was added when that variable was added)
  #
  def var_to_restriction(var)
    # restriction num = basis size + var num - vars count
    a.size1 + var - a.size2
  end

  # Variable that was added with this restriction
  #
  def restriction_to_var(restr)
    restr - a.size1 + a.size2
  end

  # Restrictions that are located lower than restr_to_remove
  #
  def restrictions_to_change(restr_to_remove)
    ((restr_to_remove + 1)...a.size1).to_a
  end

  # Subtract 'which' row from 'from' row in matrix and b vector
  # (denote 'which' variable in terms of others and substitute)
  #
  def subtract_row(linear_task, from, which)
    which_col = restriction_to_var(which)
    from_col = restriction_to_var(from)

    linear_task.b[from] = linear_task.b[from] - linear_task.a[from, which_col] * linear_task.b[which] / linear_task.a[which, which_col]
    log("b[#{from}] = #{linear_task.b[from]}")

    0.upto(from_col - 1) do |j| # upto from_col, not which_col becase we can subtract not only neighbour rows
      log("a[#{from}, #{j}] = a[#{from}, #{j}] - a[#{from}, #{which_col}] * a[#{which}, #{j}]")
      log("= #{linear_task.a[from, j]} - #{ linear_task.a[from, which_col]} * #{linear_task.a[which, j]}")
      linear_task.a[from, j] = linear_task.a[from, j] - linear_task.a[from, which_col] * linear_task.a[which, j] / linear_task.a[which, which_col] # linear_task.a[which, which_col] = 1 or -1
      log("= #{linear_task.a[from, j]}")
    end
    # values in columns more than from_col should be zero anyway
  end

  def remove_var_from_task(linear_task, row, column)
    a = linear_task.a.remove_row(row).remove_col(column)
    b = Matrix.from_gsl(linear_task.b).remove_row(row).gsl_matrix
    c = linear_task.c.remove_row(column)
    LinearTask.new(a: a, b: b, c: c)
  end

  def remove_var_from_plan(basis_plan, row)
    new_vector = Matrix.from_gsl(basis_plan.x).remove_row(row)
    new_indices = (basis_plan.basis_indexes - [row]).map do |bas_idx|  # shift all indices more than row one time left
      bas_idx > row ? bas_idx - 1 : bas_idx
    end

    BasisPlan.new(new_vector, new_indices)
  end

  def remove_artificial_var
    art_var = var_number_to_remove
    log("removing artificial variable #{art_var}")
    # do nothing if this variable corresponds to the last row

    str_to_remove = var_to_restriction(art_var)
    str_to_change = restrictions_to_change(str_to_remove)
    log("restriction ##{str_to_remove}, will change restrictions #{str_to_change}")
    # MODIFYING CURRENT TASK
    new_task = current_task.clone
    str_to_change.each do |restr_num|
      subtract_row(new_task.task, restr_num, str_to_remove)
    end
    log("Task after subtracting row")
    log_task(new_task.task)

    new_linear_task = remove_var_from_task(new_task.task, str_to_remove, art_var)
    new_basis_plan = remove_var_from_plan(current_basis_plan, art_var)
    log("Task after removing row and column")
    log_task(new_linear_task)
    log("Basis plan")
    log_plan(new_basis_plan)

    @current_task = Tasks::Simplex.new(new_linear_task, new_basis_plan)
    @current_basis_plan = new_basis_plan
  end

  def has_artificial_var?
    !(current_basis_plan.basis_indexes - @natural_indices).empty?
  end

  def calculate_current_target_function
    return unless current_basis_plan
    x_gsl = current_basis_plan.x.respond_to?(:gsl_matrix) ? current_basis_plan.x.gsl_matrix : current_basis_plan.x
    (current_task.task.c_string * x_gsl).get(0)
  end

  def log_task(linear_task)
    linear_task.print if logging
  end

  def log_current_task
    log("Created task")
    log_task(current_task.task)
    log("Found first plan for it")
    log_plan(current_task.plan)
  end

  def log_plan(basis_plan)
    log("#{basis_plan.x_ary}, basis #{basis_plan.basis_indexes}")
  end

  def log_current_task_solved
    log("Solved")
    log_status
    log_optimal_plan
  end

  def log_status
    log("Status: #{status}")
  end

  def log_optimal_plan
    return unless current_basis_plan
    log("Current task optimal plan:")
    log_plan(current_basis_plan)
    log("Target function: #{current_target_function}")
  end

  def log(string)
    puts string if logging
  end

  def integer_task
    @integer_task ||= Integer::Task.new(current_task.task, nil, current_task.indices, lower: 0)
  end
end
