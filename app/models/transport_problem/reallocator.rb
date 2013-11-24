module TransportProblem
  # Given a non-basis cell, composes a cycle with it,
  # marks edges with + and -, starting at +,
  # finds a minimum X value at '-'  edges
  # and subtracts it from '-' edges and adds to '+'.
  #
  class Reallocator
    attr_reader :basis_plan, :start_cell, :new_plan

    def initialize(basis_plan, start_cell)
      @basis_plan = basis_plan
      @new_plan = basis_plan.clone

      @start_cell = start_cell
      @cells_with_cycle = Matrices::CellSet.new(basis_plan.basis + [start_cell])
    end

    def self.process(basis_plan, start_cell)
      new(basis_plan, start_cell).reallocate
    end

    # @return [BasisPlan] new basis plan
    #
    def reallocate
      cycle_plus, cycle_minus = mark
      value = reallocation_value(cycle_minus)
      subtract(cycle_minus, value)
      add(cycle_plus, value)
      new_plan
    end

    def reallocation_cell
      cycle_plus, cycle_minus = mark
      reallocation_value_idx(cycle_minus)
    end

    def cycle
      @cycle ||= Matrices::CycleFinder.new(@cells_with_cycle).find_any(start_cell)
    end

    # @return [Array] [cycle plus, cycle minus]
    #
    def mark
      cycle_plus = []
      cycle_minus = []

      cycle.each_slice(2) do |cell_plus, cell_minus|
        cycle_plus << cell_plus
        cycle_minus << cell_minus
      end
      [Matrices::CellSet.new(cycle_plus), Matrices::CellSet.new(cycle_minus)]
    end

    def subtract(cells, value)
      cells.each do |cell|
        new_plan[cell] -= value
      end
    end

    def add(cells, value)
      cells.each do |cell|
        new_plan[cell] += value
      end
    end

    # Cell with minimal plan value of all cells in cells
    #
    def reallocation_value_idx(cells)
      colcount = basis_plan.plan.size2
      cells.sort_by { |c| c.row * colcount + c.column }.min_by { |c| basis_plan[c] }
    end

    def reallocation_value(cells)
      basis_plan[reallocation_value_idx(cells)]
    end
  end
end
