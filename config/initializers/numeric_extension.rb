class Numeric
  def neg?
    self < 0
  end

  def pos?
    self > 0
  end

  def nonneg?
    self >= 0
  end

  def nonpos?
    self <= 0
  end

  def zero?
    self == 0
  end

  def nonzero?
    !zero?
  end
end
