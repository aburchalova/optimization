class Matrices::Cell < DelegateClass(Array)
  # inner array = [row, column]

  def row
    self[0]
  end

  def column
    self[1]
  end

  # If cells share row or column
  # or they are equal cells
  # TODO: check if equal cells should return true
  #
  def share_item?(cell)
    row == cell.row || column == cell.column
  end
end
