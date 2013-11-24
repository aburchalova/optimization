module TransportProblem
  class Optimality

    attr_accessor :data, :basis, :u, :v

    # @param data [Data]
    # @param basis [Matrices::Chain]
    # @param
    def initialize(data, basis, u_and_v)
      @data = data
      @basis = basis
      @u = u_and_v.first
      @v = u_and_v.last
    end

    # @return [Matrix]
    #
    def estimates
      @estimates ||= calculate_estimates
    end
    alias :reduced_costs :estimates

    # @return [Matrices::Cell, nil] nil if all estimates non-negative
    #
    def negative_estimate_cell
      idx = estimates.min_index
      return Matrices::Cell.new(idx) if estimates[idx] < 0
    end

    def positive_estimate_cell
      idx = estimates.max_index
      return Matrices::Cell.new(idx) if estimates[idx] > 0
    end

    protected

    def calculate_estimates
      est = Matrix.zeros(u.length, v.length)
      u.each_with_index do |ui, i|
        fill_row(est, ui, i)
      end
      Matrix.from_gsl(est)
    end

    def fill_row(est, ui, i)
      v.each_with_index do |vj, j|
        est[i, j] = ui + vj - data.c[i, j]
      end
    end

  end
end
