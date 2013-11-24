require 'spec_helper'

describe TransportProblem::Potentials do
  let(:data) { TransportProblem::Data.new(
    Array.new(2, 3), 
    Array.new(3, 2), 
    Matrix.new( [1, 2, 3], [4, 5, 6] ) 
  )}
  let(:basis) { Matrices::CellSet.new([[0, 0], [0, 1], [1, 1], [1, 2]]) }
  let(:finder) { described_class.new(data, basis) }

  describe '#compose_helper_matrix' do

    subject(:matrix) { finder.compose_helper_matrix }

    it 'composes matrix 5 * 5' do
      matrix.size1.should == 5
      matrix.size2.should == 5
    end

    it 'sets last equation to u0 = 0' do
      matrix[4, 0].should == 1
    end

    let(:u_matrix) { matrix.cut([0, 1]) }
    it 'sets ones for u0 in basis cells' do
      u_matrix[0, 0].should == 1
      u_matrix[1, 0].should == 1
    end

    it 'sets ones for u1 in basis cells' do
      u_matrix[2, 1].should == 1
      u_matrix[3, 1].should == 1
    end

    let(:v_matrix) { matrix.cut([2, 3, 4]) }
    it 'sets ones for v0 in basis cells' do
      v_matrix[0, 0].should == 1
    end

    it 'sets ones for v1 in basis cells' do
      v_matrix[1, 1].should == 1
      v_matrix[2, 1].should == 1
    end

    it 'sets ones for v2 in basis cells' do
      v_matrix[3, 2].should == 1
    end
  end

  describe '#compose_prod_from_costs' do
    subject(:vector) { finder.compose_prod_from_costs }
    let(:vector_ary) { vector.to_a.flatten }

    it 'is a vector of size 5' do
      vector.size1.should == 5
      vector.size2.should == 1
    end

    it 'first items are basis cells costs' do
      0.upto(3) do |i|
        vector_ary[i].should == data.c[*basis[i].to_a]
      end
    end

    it 'last item is 0 as u0 = 0' do
      vector_ary[4].should == 0
    end
  end

  describe '#find' do
    subject(:potentials) { finder.find }
    let(:u) { potentials.first }
    let(:v) { potentials.last }

    it 'calculates u' do
      u.should == [0, 3]
    end

    it 'calculates v' do
      v.should == [1, 2, 3]
    end
  end
end
