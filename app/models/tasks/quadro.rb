module Tasks
  class Quadro
    attr_accessor :proper_data

    delegate :singular_pillar_matrix?, :pillar_plan, :plan, :pillar_indices, :proper_indices, :to => :proper_data

    def initialize(proper_data)
      @proper_data = proper_data
    end

    def optimality_service
      @optimality ||= ::Quadro::Optimality.new(proper_data)
    end
    delegate :optimal?, :negative_estimate_idx, :pivot_estimate, to: :optimality_service

    def steps_service
      @steps ||= ::Quadro::Steps.new(
        proper_data,
        estimates[negative_estimate_idx],
        negative_estimate_idx
      )
    end
    delegate :has_step?, :step, :step_index, :direction, :direction_value, to: :steps_service

    def with_data(new_proper_data)
      self.class.new(new_proper_data)
    end

    def with(hash)
      pill = hash.fetch(:pillar, pillar_indices)
      prop = hash.fetch(:proper, proper_indices)
      plan = hash.fetch(:plan, plan)

      pillar_plan = ::Quadro::PillarPlan.new(plan, pill)
      new_proper_data = ::Quadro::ProperPillarData.new(proper_data.data, pillar_plan, pill)
      self.class.new(new_proper_data)
    end

    # Position of j*, or step index, in pillar indices,
    # or nil if it is out of them
    #
    def step_index_pillar_position
      pillar_indices.index(step_index)
    end

    def estimates
      # @estimates ||= 
      optimality_service.estimates
    end

    # For step recalculation
    def estimates=(new_est)
      if new_est && estimates.length != new_est.length
        raise ArgumentError, 'WTF? Wrong length new estimates!'
      end
      optimality_service.estimates = new_est
    end

    def needs_step_recalculation?
      ::Quadro::PillarChanger.needs_change?(proper_data, step_index)
    end

    def target_function
      proper_data.c.transpose * plan + (plan.transpose * proper_data.d.gsl_matrix * plan)/2
    end
  end
end
