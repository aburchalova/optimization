class TransportProblem::CornerFirstPlan < TransportProblem::FirstPlan

  def find
    while !data.empty?
      update_with_upper_left_item
    end
    result
  end

  def update_with_upper_left_item
    cell = data.upper_left_cell
    a, b = data.a_b_for_min_c
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
end