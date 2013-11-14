class Float < Numeric
  COMPARISON_PRECISION = 1.0/10**8

  def lt?(other)
    self - other < -COMPARISON_PRECISION
  end

  def gt?(other)
    self - other > COMPARISON_PRECISION
  end

  def eq?(other)
    (self - other).abs <= COMPARISON_PRECISION
  end

  def gte?(other)
    gt?(other) || eq?(other)
  end

  def lte?(other)
    lt?(other) || eq?(other)
  end

  def <=>(other)
    return if to_f.nan? || other.to_f.nan?
    return -1 if lt?(other)
    return 1 if gt?(other)
    return 0
  end

  def ==(other)
    (self <=> other) == 0
  end

  def neg?
    lt? 0
  end

  def pos?
    gt? 0
  end

  def nonneg?
    gte? 0
  end

  def nonpos?
    lte? 0
  end

  def zero?
    eq? 0
  end

  def nonzero?
    !zero?
  end
end
