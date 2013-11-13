module Solvers
  class DualSimplex < Solvers::Base
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
      @status.step_completed!
    end

    def initialize(task_with_plan)
      @initial_task = task_with_plan
      @task = task_with_plan
      @status = Statuses::Simplex[:initialized]
      @new_task_composer_class = NewTaskComposers::DualSimplex
      @logging = false
      self
    end
  end
end
