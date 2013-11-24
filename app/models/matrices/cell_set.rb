module Matrices
  class CellSet < DelegateClass(Array)

    # @param ary [Array<Array<Fixnum>, Matrices::Cell>]
    #
    # @example
    #
    # Matrices.CellSet.from([1, 2], [2, 3])
    #
    def initialize(ary = [])
      # create cells from arrays
      ary_of_cells = ary.map do |ary_or_cell|
        ary_or_cell.respond_to?(:row) ? ary_or_cell : Matrices::Cell.new(ary_or_cell)
      end
      super(ary_of_cells)
    end

    # @return [Matrices::CellChain, nil] nil if no cycle in this set
    #
    def extract_cycle(from, to)
      working_set = clone
      working_set.remove_rows_and_cols_with_1_item!
      CycleFinder.new(working_set).find(from, to) # TODO: add finding cycle starting at any cell?
    end

    def has_cycle?
      # remove all rows and columns in the cost matrix that have only 1 item
      # if nothing left - no cycle
      working_chain = clone
      working_chain.remove_rows_and_cols_with_1_item!
      !working_chain.empty?
    end

    # Returns true if at least one row was removed
    #
    def remove_rows_with_1_item!
      # select cells that have row neighbours
      old_length = length
      select! { |cell| has_row_neighbours?(cell) }
      old_length != length
    end

    # cell should be an item of chain
    #
    def has_row_neighbours?(cell)
      find_all_indices { |c| c.row == cell.row }.length > 1
    end

    # Returns true if at least one column was removed
    #
    def remove_columns_with_1_item!
      # select cells that have row neighbours
      old_length = length
      select! { |cell| has_column_neighbours?(cell) }
      old_length != length
    end

    # cell should be an item of chain
    #
    def has_column_neighbours?(cell)
      find_all_indices { |c| c.column == cell.column }.length > 1
    end

    def remove_rows_and_cols_with_1_item!
      loop do
        rows_removed = remove_rows_with_1_item!
        cols_removed = remove_columns_with_1_item!
        break unless (rows_removed || cols_removed)
      end
    end

    def clone
      Matrices::CellSet.new(__getobj__.clone)
    end

    # @return [Array] all cells in the same row with given
    #
    def all_row_neighbours(cell)
      select{ |c| c.same_row?(cell) && c != cell }
    end

    # @return [Array] all cells in the same col with given
    def all_col_neighbours(cell)
      select{ |c| c.same_col?(cell) && c != cell }
    end

    def equal_items?(set)
      all? { |cell| set.include?(cell) }
    end

  end
end
