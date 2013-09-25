require 'spec_helper'
require 'shared_examples_for_optimization_labs'

describe Matrix do
  it_behaves_like "optimization labs"

  describe '.cut' do
    let(:matrix) { Matrix.from_gsl(Matrix.eye(3)) }
    let(:first_two) { Matrix.new( [1, 0], [0, 1], [0, 0] ) }
    it { matrix.cut([0, 1]).should == first_two }
  end
end
