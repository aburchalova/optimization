module Quadro
  class ProperPillarData < PillarData
    attr_accessor :proper_indices

    def initialize(data, pillar_plan, proper_indices)
      super(data, pillar_plan)
      self.proper_indices = proper_indices
    end

    # H*, or KKT matrix (Karush–Kuhn–Tucker)
    def block_matrix

    end

    def proper_a
      @proper_a ||= a.cut(proper_indices)
    end

    def proper_a_t
      @proper_a_t ||= proper_a.transpose
    end

    def proper_d
      @proper_d ||= d.cut(proper_indices)
    end
  end
end