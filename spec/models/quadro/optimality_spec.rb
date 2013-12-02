require 'spec_helper'

describe Quadro::Optimality do
  let(:data) { double(:QuadroData,
                      :a => Matrix.new([0, 1, 1], [1, 1, 0]),
                      :dependent_c_ary => [3, 1, 2],
                      :pillar_dependent_c => Matrix.new_vector([2, 3]),
                      :inverse_pillar_matrix => Matrix.eye(2))
               }
  subject(:optimality) { described_class.new(data) }

  describe '#negative_estimate_idx' do
    before { optimality.stub(:estimates => [0, -1, 2, -3]) }

    it { optimality.negative_estimate_idx.should == 1 }
  end

  describe '#potentials_string' do
    subject(:potentials_string) { optimality.potentials_string }

    it 'has colcount as task matrixs rowcount' do
      potentials_string.size2.should == 2
    end

    it { potentials_string.should == GSL::Matrix[[-2, -3]] }
  end

  describe '#estimates' do
    let(:potentials_string) { Matrix.new([-2, -3]) }
    before do
      optimality.stub(:potentials_string => potentials_string)
    end

    it { optimality.estimates.should == [0, -4, 0] }
  end

  describe '#optimal?' do
    before { optimality.stub(:estimates => [0, -4, 0]) }

    it { optimality.optimal?.should be_false }
  end
end