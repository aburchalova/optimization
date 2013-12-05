module NewTaskComposers
  class Quadro
    attr_accessor :task
    attr_accessor :changed_pillar

    def initialize(task)
    # If step index is in pillar indices, tries to change pillar so that step index will be
    # out of it but pillar matrix will stay non-singular
    #
      if task.needs_step_recalculation? &&
          new_proper_data = ::Quadro::PillarChanger.new(task.proper_data, task.step_index_pillar_position).new_proper_data
        @task = task.with_data(new_proper_data)
        @changed_pillar = true
      else
        @task = task
      end
    end

    def compose
      task.with(
        :proper => new_proper,
        :pillar => new_pillar,
        :plan => new_plan
      ).tap { |t| t.estimates = new_estimates }
    end

    # in task needs direction and step recalculation
    # changing estimate that was pivot (chosen as negative estimate index)
    #
    def new_estimates
      if changed_pillar
        new_estimate = task.pivot_estimate + task.step * task.direction_value
        task.estimates.dup.tap { |est_ary| est_ary[task.negative_estimate_idx] = new_estimate }
      else
        task.estimates.dup
      end
    end

    def new_plan
      @new_plan ||= task.plan + task.step * task.direction
    end

    def new_pillar
      new_basis_composer.new_pillar
    end

    def new_proper
      new_basis_composer.new_proper
    end

    def new_basis_composer
      @new_basis_composer ||= ::Quadro::NewBasisComposers::Base.for(task.pillar_indices, task.proper_indices,
        task.negative_estimate_idx, task.step_index)
    end
  end
end
