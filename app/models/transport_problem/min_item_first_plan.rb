class TransportProblem::MinItemFirstPlan < TransportProblem::FirstPlan

  def find
    while !data.empty?
      update_with_min_item
    end

    complete_basis
    result
  end

  def update_with_min_item
    cell = data.min_c_cell
    a, b = data.a_b_for_min_c # PROBLEM: as matrix rows/cols are removed, indices are not valid
    a < b ? add_a_to_plan(cell) : add_b_to_plan(cell)
  end

  # if adding a to plan, a row should be removed from
  # c matrix and b item should be updated
  #
  # Modifies plan and data
  #
  def self.add_a_to_plan(cell)
    a = data.a[cell.row]
    result[cell] = a
    data.delete_row!(cell.row)
    data.b[cell.column] -= a
  end

  def self.add_b_to_plan(cell)
    b = data.b[cell.column]
    result[cell] = b
    data.delete_column!(cell.column)
    data.a[cell.row] -= b
  end

  def items_to_add_number
    desired_basis_size - basis_size
  end

  def complete_basis
    uk = result
    1.upto(items_to_add_number) do |k| #TODO: don't need k?
      uk = cell_to_add_without_cycle(uk)
    end
  end

  # Adds one cell so that result doesn't contain cycles
  #
  # @param basis [TransportProblem::Basis] set of cells without cycle
  #
  # @return [TransportProblem::Basis] new basis
  #
  def add_cell_without_cycle(basis) #TODO:not here? return or modify?

  end
end