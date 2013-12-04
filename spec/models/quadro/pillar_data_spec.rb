require 'spec_helper'

describe Quadro::PillarData do
  let(:a) { Matrix.new([0, 1, 1], [1, 1, 0]) }
  let(:b) { Matrix.new_vector([1, 2]) }
  let(:c) { Matrix.new_vector([1, 1, 1]) }
  let(:d) { Matrix.eye(3) }
  let(:dat) { Quadro::Data.new(:a => a, :b => b, :c => c, :d => d) }

  let(:plan) { Quadro::PillarPlan.new(Matrix.new_vector([2, 0, 1]), [2, 0]) }
  subject(:data) { Quadro::PillarData.new(dat, plan) }

  describe '#dependent_c' do
    it { data.dependent_c.should == Matrix.new_vector([3, 1, 2]) }
  end

  describe '#pillar_matrix' do
    it { data.pillar_matrix.should == Matrix.new([1, 0], [0, 1]) }
  end

  describe '#inverse_pillar_matrix' do
    it { data.inverse_pillar_matrix.should == Matrix.eye(2) }
  end

  describe '#pillar_dependent_c' do
    it { data.pillar_dependent_c.should == Matrix.new_vector([2, 3]) }
  end

  describe '#indices' do
    it { data.indices.should == [0, 1, 2] }
  end

  describe '#change_pillar' do
    subject { data.change_pillar(1, 1).pillar_indices }
    it { should == [2, 1] }
  end
end
