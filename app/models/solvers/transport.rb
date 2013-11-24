module Solvers
  class Transport < Solvers::Base
    def calculate_and_change_status
      return @status.incompatible! if !task.compatible?
      return @status.optimal! if task.sufficient_for_optimal?
      return @status.step_completed!
    end

    def initialize(task)
      @initial_task = task
      @task = task.clone
      @status = Statuses::Transport[:initialized]
      @new_task_composer_class = NewTaskComposers::Transport
      @logging = false
      self
    end

    def result
      iterate
      status.data = (optimal? ? task.basis_plan.plan : nil)
      status
    end

    def result_plan
      result.data
    end

    def result_ary
      raise NotImplementedError
      result.data.try(:to_a)
    end

    def initial_status
      return unless @status.initialized?
      %Q(
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #{task.data.to_s}
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~)
    end
  end
end
