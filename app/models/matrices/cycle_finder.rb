module Matrices
  class CycleFinder < ChainFinder
    MIN_CYCLE_LENGTH = 4

    # Returns first found cycle from one cell to another.
    # from and to should be in the same row or column.
    # Actually returns chain that's longer than 3 cells
    #
    # @param from [Cell]
    # @param to [Cell]
    #
    def find(from, to)
      return unless valid_start_end?(from, to)

      horiz_traverse = go_horizontal(from, to)
      return horiz_traverse if valid_cycle?(horiz_traverse)
      vert_traverse = go_vertical(from, to)
      return vert_traverse if valid_cycle?(vert_traverse)
    end

    def valid_cycle?(chain)
      chain && 
        chain.length >= MIN_CYCLE_LENGTH && 
        chain.length % 2 == 0
    end

    def valid_start_end?(from, to)
      from.share_item?(to)
    end

    # If they are in the same row or column
    #
    def raise_if_invalid_start_end(from, to)
      unless valid_start_end?(from, to)
        raise ArgumentError, "#{from} and #{to} can't be a start and end of cycle!"
      end
    end

    # cycle starting at from and ending at any cell
    #
    def find_any(from)
      (cells_set.all_row_neighbours(from) + cells_set.all_col_neighbours(from)).each do |cell_end|
        cycle = find(from, cell_end)
        return cycle if cycle
      end
    end
  end
end
