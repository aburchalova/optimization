require 'spec_helper'

describe Quadro::PillarChanger do
  let(:a) { Matrix.new([1, 0, 1, 1], [0, 1, 0, 1]) } #0th and 2nd cols equal
  let(:qd) { Quadro::Data.new(:a => a) }
  let(:plan) { double(:PillarPlan, :pillar_indices => [0, 1]).as_null_object }
  let(:data) { Quadro::ProperPillarData.new(qd, plan, [0, 1, 2, 3]) }

  subject(:changer) { Quadro::PillarChanger.new(data, 1) }
  describe '#valid_data?' do
    it { changer.valid_data?.should be_true }
  end

  describe '#adding_candidates' do
    it { changer.adding_candidates.should == [2, 3] }
  end

  describe '#new_proper_data' do
    subject { changer.new_proper_data }
    it 'doesnt make matrix singular' do
      subject.pillar_matrix.det.should_not be_zero
    end

    it 'adds one index to pillar and removes one' do
      subject.pillar_indices.should == [0, 3]
    end

    context 'when matrix is singular with any other column' do
      let(:a) { Matrix.new([1, 0, 1, 1], [0, 1, 0, 0]) }
      it 'returns nil' do
        subject.should be_nil
      end
    end
  end
end
