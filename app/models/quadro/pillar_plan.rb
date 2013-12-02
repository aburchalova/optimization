module Quadro
  class PillarPlan
    attr_accessor :plan, :pillar_indices

    def initialize(plan, pillar_indices)
      self.plan = plan
      self.pillar_indices = pillar_indices
    end
  end
end