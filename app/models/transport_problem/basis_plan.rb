class TransportProblem::BasisPlan
  attr_accessor :basis, :plan

  def initialize(plan, basis = nil)
    @basis = basis || Matrices::CellSet.new
    @plan = plan
  end

  # initializes new with blank plan
  #
  def self.blank(rowcount, colcount)
    new(TransportProblem::Plan.blank(rowcount, colcount))
  end

  def include?(cell)
    basis.include?(cell)
  end

  def []=(cell, value)
    plan.set(cell[0], cell[1], value)
  end

  def [](cell)
    plan.get(cell[0], cell[1])
  end

  def clone
    self.class.new(plan.clone, basis.clone)
  end

  def to_s
    "plan: \n#{plan.to_a}\nbasis: #{basis}"
  end

end
