# Call this one when j* in proper indices but not in pillar
#
class Quadro::NewBasisComposers::RemovingProper < Quadro::NewBasisComposers::Base
  def initialize(pillar, proper, j0, jstar)
    super(pillar, proper, j0, jstar)
  end

  def new_pillar
    @pillar.dup
  end

  def new_proper
    @proper.dup.tap { |ary| ary - [@jstar] }
  end

end