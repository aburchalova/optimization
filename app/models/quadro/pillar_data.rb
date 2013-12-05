module Quadro
  class PillarData
    attr_accessor :data, :pillar_plan

    delegate :a, :b, :c, :d, :indices, :rowcount, :colcount, :to => :data
    delegate :pillar_indices, :plan, :to => :pillar_plan

    def initialize(data, pillar_plan)
      self.data = data
      self.pillar_plan = pillar_plan
    end

    def dependent_c
      @dependent_c ||= data.dependent_c(plan)
    end

    def pillar_dependent_c
      @pillar_dependent_c ||= dependent_c.cut_rows(pillar_indices)
    end

    def dependent_c_ary
      @dependent_c_ary ||= dependent_c.to_a.flatten
    end

    def pillar_matrix
      @pillar_a ||= data.a.cut(pillar_indices)
    end
    alias :pillar_a :pillar_matrix

    def singular_pillar_matrix?
      @singular_pillar_matrix ||= pillar_matrix.det == 0
    end

    def inverse_pillar_matrix
      @inverse_pillar_matrix ||= pillar_matrix.invert
    end
    alias :inverse_pillar_a :inverse_pillar_matrix

    # Change +what+ index from pillar indices by
    # +by+ index not from them
    #
    # @param what_index [Fixnum] index of index to remove
    # @param by [Fixnum] index to add
    #
    # @return [PillarPlan] new pillar plan
    #
    def change_pillar_plan(what_index, by)
      new_indices = pillar_indices.dup
      new_indices[what_index] = by
      PillarPlan.new(plan, new_indices)
    end

    # @return [PillarData] new data
    #
    def change_pillar(what_index, by)
      PillarData.new(data, change_pillar_plan(what_index, by))
    end

    def clone
      PillarData.new(data.clone, pillar_plan.clone)
    end

  end
end
