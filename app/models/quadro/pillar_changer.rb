module Quadro
  # Changes pillar indices (removes index_to_remove that belongs to pillar indices
  # and adds a proper index), leaving proper indices set the same,
  # so that pillar matrix stays invertible (det not zero)
  #
  class PillarChanger
    attr_accessor :proper_data, :index_to_remove_index

    # index_to_remove_index is position if step index in pillar
    #
    def initialize(proper_data, index_to_remove_index)
      @proper_data = proper_data
      @index_to_remove_index = index_to_remove_index
    end

    def self.needs_change?(proper_data, index_to_remove)
      proper_data.pillar_indices.include?(index_to_remove)
    end

    def index_to_remove
      @j ||= proper_data.pillar_indices[index_to_remove_index]
    end

    # if
    # 1. index_to_remove belongs to pillar indices
    # 2. there are proper indices that don't belong to pillar indices
    #
    def valid_data?
      proper_data.pillar_indices.include?(index_to_remove) &&
        !adding_candidates.empty?
    end

    def new_proper_data
      return unless valid_data?
      @new_proper_data ||= adding_candidates.each do |candidate|
        return proper_data.change_pillar(index_to_remove_index, candidate) if can_add?(candidate)
      end
      return
    end

    # proper indices but not pillar
    #
    def adding_candidates
      @adding_candidates ||= proper_data.proper_indices - proper_data.pillar_indices
    end

    # if pillar matrix with this candidate will be inversible
    #
    def can_add?(candidate)
      e = Matrix.eye_row(:size => proper_data.a.size1, :index => index_to_remove_index)
      k = candidate_index(candidate)
      alpha = e * proper_data.inverse_pillar_matrix * proper_data.a.column(k)
      alpha.nonzero?
    end

    def candidate_index(candidate)
      proper_data.proper_indices.index(candidate)
    end

    # # Variable to remove from pillar index in pillar
    # #
    # def index_to_remove_index
    #   @k ||= proper_data.pillar_indices.index(index_to_remove)
    # end
  end
end
