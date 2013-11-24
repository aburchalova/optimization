module Matrices
  class ChainFinder
    attr_accessor :cells_set

    def initialize(cells_set)
      @cells_set = cells_set.respond_to?(:all_row_neighbours) ? 
        cells_set :
        CellSet.new(cells_set)
    end

    # Returns first found chain from one cell to another.
    # Starts traversing horizontally =>
    # when from and to are in the same row, it will return
    # the chain of 2 items even if there can be more.
    #
    # @param from [Cell]
    # @param to [Cell]
    #
    def find(from, to)
      go_horizontal(from, to) || go_vertical(from, to)
    end

    def go_horizontal(cell_from, cell_to)
      return CellSet.new([cell_to]) if cell_from == cell_to

      cells_set.all_row_neighbours(cell_from).each do |current_cell|
        path_rest = go_vertical(current_cell, cell_to)
        return CellSet.new([cell_from] + path_rest) if path_rest
      end
      return
    end

    def go_vertical(cell_from, cell_to)
      return CellSet.new([cell_to]) if cell_from == cell_to

      cells_set.all_col_neighbours(cell_from).each do |current_cell|
        path_rest = go_horizontal(current_cell, cell_to)
        return CellSet.new([cell_from] + path_rest) if path_rest
      end
      return
    end


  end
end
