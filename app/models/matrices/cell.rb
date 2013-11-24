class Matrices::Cell < DelegateClass(Array)
  # inner array = [row, column]

  def row
    self[0]
  end

  def row=(i)
    self[0] = i
  end

  def column
    self[1]
  end

  def column=(i)
    self[1] = i
  end

  # If cells share row or column
  # or they are equal cells
  # TODO: check if equal cells should return true
  #
  def share_item?(cell)
    row == cell.row || column == cell.column
  end

  def to_a
    __getobj__
  end

  def clone
    Matrices::Cell.new(__getobj__.clone)
  end

  def same_col?(cell2)
    column == cell2.column
  end

  def same_row?(cell2)
    row == cell2.row
  end

  def inc_col!
    self.column += 1
  end
  alias :right! :inc_col!

  def inc_row!
    self.row += 1
  end
  alias :down! :inc_row!

  def dec_col!
    self.column -= 1
  end
  alias :left! :dec_col!

  def dec_row!
    self.row -= 1
  end
  alias :up! :dec_row!

  %w(right down left up).each do |meth_name|
    define_method(meth_name) { clone.tap { |c| c.send("#{meth_name}!") } }
  end
end
