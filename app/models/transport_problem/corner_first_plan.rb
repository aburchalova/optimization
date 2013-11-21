class TransportProblem::CornerFirstPlan < TransportProblem::FirstPlan

  def find
    current_cell = Matrices::Cell.new([0, 0])
    desired_basis_size.times do      
      update_to_next_cell(current_cell)      
    end
    result
  end

  def update_to_next_cell(current_cell)
    debugger
    a, b = data.a_b_for(current_cell)
    if a < b
      update_result(current_cell, a)
      data.b[current_cell.column] -= a
      current_cell.row += 1
    else
      update_result(current_cell, b)
      data.a[current_cell.row] -= b
      current_cell.column += 1
    end
    current_cell
  end

  def update_result(cell, value)
    result.chain << cell
    result.plan[cell] = value
  end
end
