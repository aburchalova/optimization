require 'spec_helper'

describe Quadro::Direction do
  let(:data) { double(:ProperData,
    :block_matrix => Matrix.new([0, 1, 0, 0], [1, 0, 0, 0], [1, 0, 0, 1], [0, 1, 1, 0]),
    :a => Matrix.new([0, 1, 1], [1, 1, 0]),
    :d => Matrix.from_gsl(Matrix.eye(3)),
    :proper_d => Matrix.new([1, 0], [0, 1]),
    :proper_indices => [0, 2]
    ) }
  let(:negative_estimate_idx) { 1 }

  subject(:direction) { Quadro::Direction.new(data, negative_estimate_idx).get }

  describe '#get' do
    it 'is a vector of size as variables count' do
      direction.size1.should == 3
      direction.size2.should == 1
    end
    it 'has 1 on negative estimate index, others are calculated' do
      direction.should == Matrix.new([-1, 1, -1]).transpose
    end

    context 'when proper and pillar sets are not equal' do

    end
  end
end
