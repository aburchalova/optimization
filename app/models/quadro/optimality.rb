module Quadro
  class Optimality
    attr_accessor :pillar_data #don't need proper data as estimate[j] == 0 for j in J* (jproper)

    def initialize(pillar_data)
      self.pillar_data = pillar_data
    end

    def optimal?
      negative_estimate_idx == nil
    end

    def negative_estimate_idx
      @negative_estimate_idx ||= estimates.index(&:neg?)
    end

    def pivot_estimate
      @pivot_estimate ||= (estimates[negative_estimate_idx] if negative_estimate_idx)
    end

    def estimates
      @estimates ||= pillar_data.dependent_c_ary.map.with_index do |cj, j| # calculating for all indices, but for pillar they will be 0
        cj + (potentials_string * pillar_data.a.cut([j]).gsl_matrix).get(0)
      end
    end

    def estimates=(new_est)
      @estimates = new_est
    end

    def potentials_string
      @potentials_string ||= - pillar_data.pillar_dependent_c.transpose * pillar_data.inverse_pillar_matrix
    end

  end
end
