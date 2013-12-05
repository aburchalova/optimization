# Call this one if negative estimate index (j0) == step index (j*)
#
class Quadro::NewBasisComposers::EqualIndices < Quadro::NewBasisComposers::Base
  def initialize(pillar, proper, j0, jstar)
    super(pillar, proper, j0, jstar)
  end

  def new_pillar
    @pillar.dup
  end

  def new_proper
    @proper.dup.tap { |ary| ary + [@j0] }
  end

end