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
    result.basis << cell
  end

  # if adding a to plan, a row should be removed from
  # c matrix and b item should be updated
  #
  # Modifies plan and data
  #
  def add_a_to_plan(cell)
    a = data.a[cell.row]
    result[cell] = a
    data.remove_row!(cell.row)
    data.b[cell.column] -= a
  end

  def add_b_to_plan(cell)
    b = data.b[cell.column]
    result[cell] = b
    data.remove_column!(cell.column)
    data.a[cell.row] -= b
  end

  def items_to_add_number
    desired_basis_size - basis_size
  end

  def complete_basis
    1.upto(items_to_add_number) do
      result.basis << cell_to_add_without_cycle(result.basis)
    end
  end

  def nonbasis_cells(current_basis)
    data.flat_all_cells - current_basis
  end

  # Adds one cell so that result doesn't contain cycles
  #
  # @param basis [TransportProblem::Basis] set of cells without cycle
  #
  # @return [Matrices::Cell] doesn't add cycle
  #
  def cell_to_add_without_cycle(current_basis)
    loop do
      cell_candidate = nonbasis_cells.sample
        basis_candidate = current_basis + [cell_candidate]
      return cell_candidate unless basis_candidate.has_cycle?
    end
  end
end