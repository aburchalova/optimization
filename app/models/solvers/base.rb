module Solvers
  class Base

    attr_accessor :task, :status, :new_task_composer_class, :logging
    delegate :optimal?, :finished?, :to => :status
    delegate :new_plan, :new_basis, :var_to_add, :var_to_remove, :to => :new_task_composer

    def step
      calculate_and_change_status
      new_task = compose_new_task
      calculate_target_function_delta(new_task)
      log_stats
      set_new_task(new_task)
      self
    end

    def new_task_composer #TODO: add memoisation in task composer and resetting in setting new task?
      new_task_composer_class.new(task)
    end

    def compose_new_task #TODO: refactor this crap and add file loading by name
      finished? ? task : new_task_composer.compose
    end

    def calculate_and_change_status
      raise "calculate_and_change_status should be implemented in #{self.class}"
    end

    def iterate
      step until finished?
    end

    def result
      iterate
      status.data = (optimal? ? task.result_plan : nil)
      status
    end

    def result_plan
      result.data
    end

    def result_ary
      result.data.try(:x_ary)
    end

    def to_s
      %Q(
        --------SIMPLEX SOLVER-----STATUS: #{status}----------------------
        #{initial_status}
        #{step_description}
        #{target_delta}
      -------------------------------------------------------------)
    end

    class << self
      def simple_init(a, b, c, plan, basis)
        task = LinearTask.new(:a => a, :b => b, :c => c)
        x = BasisPlan.new(plan, basis)
        [task, x]
      end
    end

    protected

    def set_new_task(new_task)
      @task = new_task
    end

    def log_stats
      puts self if logging
    end

    def calculate_target_function_delta(new_task)
      @target_function_delta = new_task.target_function - task.target_function
    end

    def initial_status
      return unless @status.initialized?
      %Q(
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #{task.task.to_s}
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~)
    end

    def target_delta
      return unless @status.step_completed?
      "Target function delta: #{@target_function_delta}\n"
    end

    def step_description
      return if @status.initialized?
      task.to_s
    end
  end
end
