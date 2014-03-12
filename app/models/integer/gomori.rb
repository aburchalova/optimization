# Class for solving tasks
# 

class Integer::Gomori
  attr_accessor :current_task, # Tasks::Simplex
                :current_basis_plan,
                :current_target_function,
                :status,
                :initial_task, #maybe will need only real indices from it
                :new_linear_task,
                :logging

  def a
    current_task.task.a
  end

  def a_b_inv
    current_task.a_b_inv
  end

  # @param task [LinearTask]
  def initialize(task)
    @initial_task = task
    @natural_indices = (0...task.a.size2).to_a # TODO: check if right size
    @new_linear_task = task
    @status = Statuses::Gomori.new
    # @logging = false
  end

  def create_simplex_task(linear_task)
    Tasks::Simplex.new(linear_task, basis_for_task(linear_task))
  end

  def iterate
    step until status.finished?
  end

  def step
    @current_task = create_simplex_task(new_linear_task)
    solve_current_task
    remove_artificial_var if has_artificial_var?
    check_optimality
    return if status.integer_solution?
    debugger
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
    result_status = Solvers::Simplex.new(current_task).result
    status.from_code!(result_status.code)
    @current_basis_plan = result_status.data
    @current_target_function = calculate_current_target_function
    log_current_task_solved
  end

  def check_optimality
    return unless @current_basis_plan
    status.integer_solution! if integer_task.satisfies_integer?(@current_basis_plan)
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
    alpha = (y * a.gsl_matrix).to_a.flatten # Array<Float>
    beta = (y * current_task.task.b).get(0) #TODO add floating
    alpha + [beta] # a flat array
  end

  # Difference between cutting plane values and their integer part
  #
  def cutting_plane_fraction_values
    cutting_plane_values.map &:fractional_part
  end

  def y_string
    i = noninteger_natural_basis_idx
    ei = Matrix.eye_row(size: a.size1, index: i)
    ei * a_b_inv
  end

  def noninteger_natural_basis_idx
    satisfying_vars_with_indices = current_basis_plan.x_ary.each_with_index.find_all do |value, idx|
      current_basis_plan.basis_indexes.include?(idx) && @natural_indices.include?(idx) && !value.int?
    end
    satisfying_vars_with_indices.first.last
  end

  def compose_cutting_plane
    # add new last column -- 0 everywhere and 1 for the new row (last one)
    a_lines = a.to_a.map { |ary| ary + [0] }
    *new_line, new_b_item = cutting_plane_fraction_values.map { |val| -val }
    new_line << 1
    # if b < 0 negotiate all
    if new_b_item < 0
      new_line = new_line.map { |val| -val }
      new_b_item *= -1
    end

    new_a_lines = a_lines + [new_line] # TODO: check if vars at basis indices will be 0
    new_b_lines = current_task.task.b.to_a + [[new_b_item]]
    new_c_lines = current_task.task.c.to_a + [[0]]
    new_b = Matrix.new(*new_b_lines).gsl_matrix # [[]] as it's a vector
    new_c = Matrix.new(*new_c_lines)
    # debugger
    @new_linear_task = LinearTask.new(a: Matrix.new(*new_a_lines), b: new_b, c: new_c)

  end

  # Removes artificial variables from result
  #
  def natural_result_ary
    current_basis_plan.x_ary.values_at(*@natural_indices)
  end

  def remove_artificial_var

  end

  def has_artificial_var?
  end

  def calculate_current_target_function
    # (current_task.task.c_string * current_basis_plan.x).get(0) if current_basis_plan
    42
  end

 def log_current_task_solved
    log("Solving task #{current_task}")
    log_status
    log_optimal_plan
  end

  def log_status
    log("Status: #{status}")
  end

  def log_optimal_plan
    log("Current task optimal plan: #{current_basis_plan}\nTarget function: #{current_target_function}")
  end

  def log(string)
    puts string if logging
  end

  def integer_task
    @integer_task ||= Integer::Task.new(current_task.task, nil, current_task.indices, lower: 0)
  end
end
