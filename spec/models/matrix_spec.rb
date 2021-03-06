require 'spec_helper'
require 'shared_examples_for_optimization_labs'

describe Matrix do
  it_behaves_like "optimization labs"

  let(:matrix) { Matrix.from_gsl(Matrix.eye(3)) }
  let(:first_two_cols) { Matrix.new( [1, 0], [0, 1], [0, 0] ) }

  describe '.cut' do
    it { matrix.cut([0, 1]).should == first_two_cols }
  end

  let(:matr_3_by_2) { first_two_cols }
  describe '#colcount' do
    it { matr_3_by_2.colcount.should == 2 }
  end

  describe '#rowcount' do
    it { matr_3_by_2.rowcount.should == 3 }
  end

  describe '#neg_row' do
    it "negotiates one row in given matrix" do
      matr_3_by_2.neg_row(0)
      matr_3_by_2.get(0, 0).should == -1
    end
  end

  describe '#remove_col' do
    it 'returns new matrix with removed column' do
      matrix.remove_col(2).should == first_two_cols
    end
  end
end
