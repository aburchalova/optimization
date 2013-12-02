module Quadro
  class PillarData
    attr_accessor :data, :pillar_plan

    delegate :a, :b, :c, :d, :to => :data
    delegate :pillar_indices, :plan, :to => :pillar_plan

    def initialize(data, pillar_plan)
      self.data = data
      self.pillar_plan = pillar_plan
    end

    def dependent_c
      @dependent_c ||= data.dependent_c(plan)
    end

    def pillar_dependent_c
      @dependent_c ||= dependent_c.cut_rows(pillar_indices)
    end

    def dependent_c_ary
      @dependent_c_ary ||= dependent_c.to_a.flatten
    end

    def pillar_matrix
      @pillar_a ||= data.a.cut(pillar_indices)
    end
    alias :pillar_a :pillar_matrix

    def inverse_pillar_matrix
      @inverse_pillar_matrix ||= pillar_matrix.invert
    end
    alias :inverse_pillar_a :inverse_pillar_matrix

  end
end