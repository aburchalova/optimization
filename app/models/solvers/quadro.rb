module Solvers
  class Quadro < Solvers::Base
    def calculate_and_change_status
      # if 'small iteration', this is not needed
      unless @status.recalculating_step?
        return @status.singular! if task.singular_pillar_matrix?
        
      end
      return @status.optimal! if task.optimal?
      return @status.unlimited! if !task.has_step?
      return @status.recalculating_step!  if task.needs_step_recalculation?
      # if needs step recalculation, we anyway compose a new task
      @status.step_completed!
    end

    def initialize(task)
      @initial_task = task
      @task = task.clone
      @status = Statuses::Quadro[:initialized]
      @new_task_composer_class = NewTaskComposers::Quadro
      @logging = false
      self
    end

    def result
      iterate
      status.data = (optimal? ? task.proper_data.plan : nil)
      status
    end

    def result_plan
      task.proper_data.plan
    end

    def result_ary
      task.proper_data.plan.to_a.flatten
    end

    def initial_status
      return unless @status.initialized?
      %Q(
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #{task.proper_data.to_s}
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~)
    end
  end
end
