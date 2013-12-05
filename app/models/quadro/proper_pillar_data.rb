module Quadro
  class ProperPillarData < PillarData
    attr_accessor :proper_indices

    def initialize(data, pillar_plan, proper_indices)
      super(data, pillar_plan)
      self.proper_indices = proper_indices
    end

    # H*, or KKT matrix (Karush–Kuhn–Tucker)
    def block_matrix
      @kkt ||= construct_kkt
    end

    def proper_a
      @proper_a ||= a.cut(proper_indices)
    end

    def proper_a_t
      @proper_a_t ||= proper_a.transpose
    end

    # cuts both rows and columns to get square matrix
    def proper_d
      @proper_d ||= d.cut(proper_indices).cut_rows(proper_indices)
    end

    # @return [PillarData] new data
    #
    def change_pillar(what_index, by)
      ProperPillarData.new(data, change_pillar_plan(what_index, by), proper_indices)
    end

    def clone
      ProperPillarData.new(data.clone, pillar_plan.clone, proper_indices.clone)
    end

    def construct_kkt
      kkt = Matrix.zeros(block_matrix_size)
      fill_proper_a(kkt)
      fill_proper_d(kkt)
      fill_proper_a_transposed(kkt)
      Matrix.from_gsl(kkt)
    end

    def block_matrix_size
      @kkt_size ||= m + k
    end

    def m
      @m ||= pillar_indices.length
    end

    def k
      @k ||= proper_indices.length
    end

    def fill_proper_a(kkt)
      m.times do |i|
        k.times do |j|
          kkt[i, j] = proper_a[i, j]
        end
      end
    end

    def fill_proper_d(kkt)
      k.times do |i|
        k.times do |j|
          kkt[m + i, j] = proper_d[i, j]
        end
      end
    end

    def fill_proper_a_transposed(kkt)
      k.times do |i|
        m.times do |j|
          kkt[m + i, k + j] = proper_a_t[i, j]
        end
      end
    end
  end
end
