module TransportProblem

  # Class for finding u (1...n) and v(1...m) -
  # suppliers' and consumers' potentials
  #
  # for each basis cell (i, j): ui + vj = cij
  #
  # They are used for calculating reduced costs, or estimates:
  # delta(i, j) = ui + vj - cij
  #
  class Potentials
    attr_accessor :data, :basis

    def self.for(data, basis)
      TransportProblem::Potentials.new(data, basis).find
    end

    # @param data [TransportProblem::Data]
    # @param basis [Matrices::Chain]
    #
    def initialize(data, basis)
      @data = data
      @basis = basis
      @u_length = data.a.length
    end

    # Tries to solve syste Ax = b where b contains costs
    # and A is matrix of zeros and ones
    # Result will be vector in which first items are u's and there go v's
    #
    def find
      matrix = compose_helper_matrix
      prod = compose_prod_from_costs
      u_and_v = (matrix.invert * prod).to_a.flatten
      extract(u_and_v)
    end

    # u0 = 0
    # for each basis cell (i, j) ui + vj = cij
    #
    def compose_helper_matrix
      matrix = Matrix.zeros(basis.length + 1)

      basis.each_with_index do |cell, matr_row|
        set_u(matrix, matr_row, cell.row)
        set_v(matrix, matr_row, cell.column)
      end

      # set u0 to 0
      set_u(matrix, basis.length, 0)
      Matrix.from_gsl(matrix)
    end

    def set_u(matrix, row, u_ind)
      matrix[row, u_ind] = 1
    end

    def set_v(matrix, row, v_ind)
      matrix[row, v_ind + @u_length] = 1
    end

    # Composes product for the helper equation of all basis cells' costs
    #
    def compose_prod_from_costs
      vect = Matrix.zeros(basis.length + 1, 1)
      basis.each_with_index do |cell, vect_row|
        vect[vect_row, 0] = data.c[cell.to_a]
      end
      vect
    end

    def extract(u_and_v)
      u = u_and_v.slice!(0, @u_length)
      v = u_and_v
      [u, v]
    end
  end
end
