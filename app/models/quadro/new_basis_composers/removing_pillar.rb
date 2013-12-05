# Call this one when j* in pillar indices and pillar can't be changed
# so that j* will be out of it (e.g. in that cases pillar matrix becomes
# singular, or Jpillar = Jproper)
#
class Quadro::NewBasisComposers::RemovingPillar < Quadro::NewBasisComposers::Base
  def initialize(pillar, proper, j0, jstar)
    super(pillar, proper, j0, jstar)
  end

  def jstar_pos
    @jstar_pos ||= @pillar.index(@jstar)
  end

  def new_pillar
    @pillar.dup.tap { |ary| ary[jstar_pos] = @j0 }
  end

  def new_proper
    @proper.dup.tap { |ary| ary[jstar_pos] = @j0 }
  end

end