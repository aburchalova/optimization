class ArtificialTasker

  # LinearTask
  attr_accessor :initial_task, :task

  def initialize(task)
    @initial_task = task
    @task = LinearTask.new(:a => new_a, :b => task.b, :c => new_c)
  end

  def find_first_plan
    @first_plan ||= BasisPlan.new first_plan_vector, first_plan_basis
  end

  def task_with_plan
    @task_with_basis ||= Tasks::Simplex.new task, @first_plan
  end

  # Processes all shit
  # @return [Statuses::Simplex]
  #
  def solve
    find_first_plan
    solver = Solvers::Simplex.new(task_with_plan)
    solver.result
  end

  def first_plan_basis
    @first_plan_basis ||= (initial_task.n...width).to_a
  end
  alias :artificial_indices :first_plan_basis

  protected

  def new_a
    @new_a ||= widen_matrix
  end

  def new_c
    @new_c ||= Matrix.new_vector(widened_c_ary)
  end

  def first_plan_vector
    Matrix.new_vector(first_plan_ary).gsl_matrix
  end

  def first_plan_ary
    Array.new(initial_task.n, 0) + task.b_ary
  end

  def widen_matrix
    eye = GSL::Matrix.eye(initial_task.m)
    Matrix.from_gsl initial_task.a.horzcat(eye)
  end

  def widened_c_ary
    Array.new(initial_task.n, 0) + Array.new(initial_task.m, -1)
  end

  def width
    @width ||= initial_task.m + initial_task.n
  end

end
