module Solvers
  class Simplex < Solvers::Base

    def self.simple_init(a, b, c, plan, basis)
      task, x = super
      new(Tasks::Simplex.new(task, x))
    end

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

    def calculate_and_change_status
      return @status.not_a_plan! if !task.basis_plan?
      return @status.singular! if task.singular_basis_matrix?
      return @status.optimal! if task.sufficient_for_optimal?
      return @status.unlimited! if task.positive_z_index == nil # if z <= 0, target function is unlimited
      @status.step_completed!
    end

    def initialize(task_with_plan)
      @initial_task = task_with_plan
      @task = task_with_plan
      @status = Statuses::Simplex[:initialized]
      @new_task_composer_class = NewTaskComposers::Simplex
      @logging = false
      self
    end
  end
end
