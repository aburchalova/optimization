# Class for solving tasks
# 

class Integer::Gomori
  attr_accessor :current_task, # Tasks::Simplex
                :current_basis_plan,
                :current_target_function,
                :status

  # @param task [LinearTask]
  def initialize(task)
    @current_task = self.class.create_simplex_task(task)

  end

  def self.create_simplex_task(linear_task)
    Tasks::Simplex.new(linear_task, basis_for_current_task)
  end

  def step
    # @current_basis_plan = basis_for_current_task
    # return unless current_basis_plan
    solve_current_task
    check_optimality
    return if status.integer_solution?
    compose_cutting_plane

  end

  # Find basis with first phase of simplex method
  def basis_for_current_task
    analyzer = FirstPhaseSimplexAnalyzer.new(current_task.task)
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

  def compose_cutting_plane

  end

  def calculate_current_target_function
    (current_task.task.c_string * current_basis_plan.x).get(0) if current_basis_plan
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
