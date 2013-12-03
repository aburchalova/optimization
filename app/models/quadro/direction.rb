module Quadro
  class Direction
    attr_accessor :proper_data, :negative_estimate_idx

    def initialize(proper_data, negative_estimate_idx)
      self.proper_data = proper_data
      self.negative_estimate_idx = negative_estimate_idx
    end

    def get
      @l ||= calculate
    end

    def length
      @l_length ||= proper_data.proper_indices.length
    end

    # first compose indices that don't belong to J* (not proper)
    # then fill proper part
    #
    def calculate
      result = Matrix.zeros(proper_data.a.size2, 1)
      result[negative_estimate_idx, 0] = 1 
      fill_proper_part(result)
    end

    def direction_proper
      @direction_proper ||= calculate_direction_proper
    end

    # find proper part of direction by solving equation with kkt matrix
    # H* * (l*, y).transpose = -(A.cut(j0), D*.cut(j0)).transpose
    # (don't care about what y is)
    #
    def calculate_direction_proper
      l_y = proper_data.block_matrix.invert * ad_helper_vector 
      # contains not needed lower part
      needed_indices = (0...length).to_a
      l = Matrix.from_gsl(l_y).cut_rows(needed_indices)
    end

    def ad_helper_vector
      @a_d_j0 ||= compose_ad_helper_vector
    end

    def compose_ad_helper_vector
      aj0 = proper_data.a.cut([negative_estimate_idx])
      d_star_j0 = proper_data.proper_d.cut([negative_estimate_idx])
      - aj0.vertcat(d_star_j0.gsl_matrix)
    end

    def fill_proper_part(direction)
      # proper index and its position in set
      proper_data.proper_indices.each_with_index do |ji, i|
        direction[ji] = direction_proper.get(i)
      end   
      direction   
    end
  end
end
