class Quadro::NewBasisComposers::Base
  def initialize(pillar, proper, j0, jstar)
    @pillar = pillar
    @proper = proper
    @j0 = j0
    @jstar = jstar
  end

  # Pillar should already be changed
  # j0 is negative estimate idx, jstar is step idx
  #
  def self.for(pillar, proper, j0, jstar)
    if j0 == jstar
      return Quadro::NewBasisComposers::EqualIndices.new(pillar, proper, j0, jstar)
    elsif (proper - pillar).include?(jstar)
      return Quadro::NewBasisComposers::RemovingProper.new(pillar, proper, j0, jstar)
    elsif pillar.include?(jstar)
      return Quadro::NewBasisComposers::RemovingPillar.new(pillar, proper, j0, jstar)
    else
      raise ArgumentError, "Cant choose proper & pillar indices composer when Jp = #{pillar}, J* = #{proper}, j0 = #{j0}, j* = #{jstar}"
    end
  end
end