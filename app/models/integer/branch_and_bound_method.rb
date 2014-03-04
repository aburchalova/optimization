require 'graph'

class Integer::BranchAndBoundMethod
  attr_accessor :task,                        # initial [Integer::Task]
                :tasks_list,                  # Array of [Tasks::RestrictedDualSimplex]
                :tasks_tree,                  # array of TaskNode or Tasks::RestrictedDualSimplex pairs
                :record,                      # target function on record plan
                :has_record,                  # if there is a record plan
                :record_plan,
                :current_task,                # Tasks::RestrictedDualSimplex that's solved currently
                :current_basis_plan,          # Optimal plan on current task
                :current_target_function,     # Target function on optimal plan
                :status,                      # Statuses::BranchAndBound
                :logging,                     # If printing log data
                :printing                     # If saving a pic with tasks tree

  # task is Integer::Task
  # options logging: false
  #         printing: false
  #         basis
  #
  def initialize(task, options = {})
    @task = task
    @has_record = false
    @record = -Float::INFINITY
    @status = Statuses::BranchAndBound.new
    @logging = options[:logging] || false
    @printing = options[:printing] || false
    @first_basis = options[:basis]
    @tasks_list = []
    @tasks_tree = []
  end

  def self.simple_init(a, b, c, integer_restrictions, sign_restrictions, options = {})
    task = Integer::Task.new(
      LinearTask.new(a: a, b: b, c: c),
      nil,
      integer_restrictions,
      sign_restrictions)
    new(task, options)
  end

  # Find a basis for the first task and add it to the list
  #
  def fill_first_task
    first_basis = @first_basis || basis_for_initial_task
    return unless first_basis # no initial basis for current task
    dual_task = Tasks::RestrictedDualSimplex.new_without_plan(
      task.task,
      first_basis,
      task.sign_restrictions
    )
    tasks_list << dual_task # add current task to queue
  end

  # One iteration: solve current task, split it, change status
  #
  def step
    log_iteration_start


    @current_task = tasks_list.shift
    status.no_tasks! and return unless current_task #empty tasks list

    solve_current_task

    return unless current_basis_plan # no optimal plan, so we don't change record and continue

    if current_target_function <= record # not interested as previsous record is higher
      status.target_less_than_record!
    elsif task.satisfies_integer?(current_basis_plan)
      change_record
    else
      split_current_task
    end
    log_status
  end

  # Solve the given task
  #
  def iterate
    fill_first_task
    step until status.finished?
    save_tree if @printing
  end

  # Record plan as Array<Fixnum>
  def record_ary
    record_plan.to_a.flatten
  end

  def solve_current_task
    result_status = Solvers::RestrictedDualSimplex.new(current_task).result
    status.from_code!(result_status.code)
    @current_basis_plan = result_status.data

    log_current_task_solved
    @current_target_function = calculate_current_target_function
    log_optimal_plan

    # replace task in the tree with new data including solution
    parent_and_child = tasks_tree.detect do |parent, child|
      child == current_task
    end
    parent_and_child[1] = current_task_to_node if parent_and_child # 1 for child
  end

  # Find basis with first phase of simplex method
  def basis_for_initial_task
    analyzer = FirstPhaseSimplexAnalyzer.new(task.task)
    analyzer.analyze
    return analyzer.basis_plan.basis_indexes if analyzer.status.got_task?
    # incompatible constraints or inner error in first phase
    status.incompatible!
    return nil
  end

  def calculate_current_target_function
    (task.task.c_string * current_basis_plan.x).get(0) if current_basis_plan
  end

  def change_record
    @record = current_target_function
    @has_record = true
    @record_plan = @current_basis_plan.x
    status.integer_solution_found!
  end

  # Add two new tasks to the list with sign restrictions
  # made from current tasks' sign restrictions splitted by
  # first noninteger variable in the optimal plan
  #
  def split_current_task
    splitter = Integer::RestrictionSplitter.new(
      current_basis_plan,
      task,
      current_task.sign_restrictions)
    new_restrictions = splitter.split_restrictions
    task1 = Tasks::RestrictedDualSimplex.new_without_plan(
      task.task,
      current_basis_plan.basis_indexes,
      new_restrictions.first
    )
    task2 = Tasks::RestrictedDualSimplex.new_without_plan(
      task.task,
      current_basis_plan.basis_indexes,
      new_restrictions.last
    )
    tasks_list << task1
    tasks_list << task2

    # replace current_task child in tree with its node representation
    node_for_curr_task = current_task_to_node

    # add parent - child pairs to the tree
    tasks_tree << [node_for_curr_task, task1]
    tasks_tree << [node_for_curr_task, task2]

    status.task_split!
    log_task_split(new_restrictions)
  end


  def current_task_to_node
    Integer::TaskNode.new(
      current_task.low_restr,
      current_task.up_restr,
      current_basis_plan.try(:x_ary),
      current_basis_plan.try(:basis_indexes),
      current_target_function
    )
  end

  def log_current_task_solved
    log("Solving task with restrictions #{current_task.sign_restrictions}")
    log_status
  end

  def log_status
    log("Status: #{status}")
    log("Removed task from list and didnt change record") if status.target_less_than_record?
    log("Found integer solution and changed record to #{current_target_function}") if status.integer_solution_found?
  end

  def log_task_split(new_restrictions)
    log("Split restrictions #{current_task.sign_restrictions}\ninto\n#{new_restrictions.first}\n#{new_restrictions.last}")
  end

  def log_optimal_plan
    log("Current task optimal plan: #{current_basis_plan}\nTarget function: #{current_target_function}")
  end

  def log_iteration_start
    log("---------------------------")
    log("Starting iteration. Record: #{record}, has record: #{has_record}, record_plan: #{record_plan}.")
    log("#{tasks_list.length} tasks in list")
  end

  def save_tree
    graph = Graph.new
    tasks_tree.each do |parent, child|
      graph.edge parent.to_node_s, child.to_node_s
    end

    graph.save("graph_#{Time.now.to_i}", 'png')
  end

  def log(string)
    puts string if logging
  end
end
