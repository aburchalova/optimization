require 'spec_helper'

describe Quadro::ProperPillarData do
  let(:a) { Matrix.new([0, 1, 1], [1, 1, 0]) }
  let(:b) { Matrix.new_vector([1, 2]) }
  let(:c) { Matrix.new_vector([1, 1, 1]) }
  let(:d) { Matrix.from_gsl(Matrix.eye(3)) }
  let(:dat) { Quadro::Data.new(:a => a, :b => b, :c => c, :d => d) }

  let(:plan) { Quadro::PillarPlan.new(Matrix.new_vector([2, 0, 1]), [2, 0]) }
  let(:proper_data) { Quadro::ProperPillarData.new(dat, plan, [0, 2]) } # J* is the same as Jp but inversed order

  describe '#proper_d' do
    it { proper_data.proper_d.should == Matrix.new([1, 0], [0, 1]) }
  end

  describe '#proper_a' do
    it { proper_data.proper_a.should == Matrix.new([0, 1], [1, 0]) }
  end

  describe '#block_matrix' do
    subject(:kkt) { proper_data.block_matrix }

    it 'has A* (m*k) as upper left block' do
      kkt.cut_rows([0, 1]).cut([0, 1]).should == Matrix.new([0, 1], [1, 0])
    end

    let(:zeros) { Matrix.from_gsl(Matrix.zeros(2, 2)) }
    it 'has zeros (m*m) as upper right block' do
      kkt.cut_rows([0, 1]).cut([2, 3]).should == zeros
    end

    it 'has D* (k*k) as lower left block' do
      kkt.cut_rows([2, 3]).cut([0, 1]).should == Matrix.new([1, 0], [0, 1])
    end

    it 'has A* transposed (k*m) as lower right block' do
      kkt.cut_rows([2, 3]).cut([2, 3]).should == Matrix.new([0, 1], [1, 0])
    end

  end

  describe '#change_pillar' do
    subject(:new_data) { proper_data.change_pillar(1, 1) }
    it { new_data.pillar_indices.should == [2, 1] }

    it 'leaves data and plan' do
      new_data.plan.should == proper_data.plan
      new_data.data.should == proper_data.data
    end
  end
end
