require 'spec_helper'

describe TransportProblem::Optimality do
  let(:data) { TransportProblem::Data.new(
                 Array.new(2, 3),
                 Array.new(3, 2),
                 Matrix.new( [1, 2, 10], [5, 5, 6] )
  )}
  let(:basis) { Matrices::CellSet.new([[0, 0], [0, 1], [1, 1], [1, 2]]) }
  let(:u_and_v) { [ [0, 3], [1, 2, 3] ] }
  let(:finder) { described_class.new(data, basis, u_and_v) }

  subject(:estimates) { finder.estimates }

  describe '#estimates' do
    it 'is zero for basis cells' do
      0.upto(3) do |i|
        estimates[*basis[i].to_a].should == 0
      end
    end

    let(:u) { [0, 3] }
    let(:v) { [1, 2, 3] }
    it 'is equal potentials sum reduced by cost' do
      estimates[0, 2].should == u[0] + v[2] - data.c[0, 2]
      estimates[1, 0].should == u[1] + v[0] - data.c[1, 0]
    end
  end

  describe '#negative_estimate_cell' do
    subject(:cell) { finder.negative_estimate_cell }
    it 'returns cell where estimate is negative' do
      estimates[*cell].should be_neg
    end
  end
end
