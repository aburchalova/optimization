class TransportProblem::CornerFirstPlan < TransportProblem::FirstPlan

  def find
    current_cell = Matrices::Cell.new([0, 0])
    desired_basis_size.times do
      next_cell = update_to_next_cell(current_cell)
      current_cell = next_cell
    end
    result
  end

  def update_to_next_cell(current_cell)
    a, b = data.a_b_for(current_cell)
    next_cell = if a < b
      choose_supplier_value(current_cell, a)
    else
      choose_consumer_value(current_cell, b)
    end
  end

  # When supplier's value is lower that consumers,
  # we're 'crossing out' that supplier and
  # decreasing consumer's at current cell's column value by value.
  # That means we can't go right (because we would stay at the same supplier)
  # so we're going down.
  #
  # Also updates result with value at current cell.
  #
  # @return [Matrices::Cell] next cell that's lower neighbour of the current one.
  #
  def choose_supplier_value(current_cell, value)
    update_result(current_cell, value)
    data.b[current_cell.column] -= value
    increase_row(current_cell)
  end

  def increase_row(current_cell)
    current_cell.clone.tap do |next_cell|
      next_cell.row += 1
    end
  end

  def choose_consumer_value(current_cell, value)
    update_result(current_cell, value)
    data.a[current_cell.row] -= value
    increase_column(current_cell)
  end

  def increase_column(current_cell)
    current_cell.clone.tap do |next_cell|
      next_cell.column += 1
    end
  end

  def update_result(cell, value)
    result.basis << cell
    result[cell] = value
  end
end
