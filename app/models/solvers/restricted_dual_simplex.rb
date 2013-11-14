module Solvers

  class RestrictedDualSimplex < Solvers::Base #TODO: refactor
    attr_accessor :used_basises

    def self.simple_init(a, b, c, basis, restr = {})
      plan = Tasks::RestrictedDualSimplex.first_basis_plan_for(a, b, c, basis)
      task = LinearTask.new(:a => a, :b => b, :c => c)
      new(Tasks::RestrictedDualSimplex.new(task, plan, restr))
    end

    def calculate_and_change_status
      return @status.not_a_plan! if !task.basis_plan?
      return @status.singular! if task.singular_basis_matrix?
      return @status.optimal! if task.sufficient_for_optimal?
      return @status.incompatible! if !task.has_step?
      handle_step_end
    end

    def initialize(task_with_plan)
      @initial_task = task_with_plan
      @task = task_with_plan
      @status = Statuses::Simplex[:initialized]
      @new_task_composer_class = NewTaskComposers::RestrictedDualSimplex
      @logging = false
      @used_basises = []
      self
    end

    # Checks if current task's  result is optimal for a plain simplex task
    #
    def check_result
      plan = BasisPlan.simple_init(task.kappa, task.basis_indexes)
      plain_task = Tasks::Simplex.new(task.task, plan, task.sign_restrictions)
      plain_task.optimal_plan?
    end

    def handle_step_end
      warn_if_zero_step
      # raise LoopError if used_basises.include? task.basis_indexes
      used_basises << task.basis_indexes
      @status.step_completed!
    end

    def warn_if_zero_step
      puts "Warning! Zero step! Took step##{task.step_index}" if task.step.zero?
    end
  end
end
