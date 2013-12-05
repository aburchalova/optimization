module Quadro
  class PillarPlan
    attr_accessor :plan, :pillar_indices

    def initialize(plan, pillar_indices)
      self.plan = plan
      self.pillar_indices = pillar_indices
    end

    def clone
      self.class.new(plan.clone, pillar_indices.clone)
    end
  end
end