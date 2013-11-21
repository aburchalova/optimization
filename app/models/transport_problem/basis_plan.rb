class TransportProblem::BasisPlan
  attr_accessor :chain, :plan

  def initialize
    @chain = Matrices::CellChain.new
    @plan = TransportProblem::Basis.new
  end

end
