require 'spec_helper'

describe 'LinearTask' do
  let(:a) { Matrix.new([1, 1, 1, 1], [1, -1, 1, -2]) }
  let(:b) { GSL::Matrix[[2, 0]].transpose }
  let(:task) { LinearTask.new(:a => a, :b => b) }

  describe "#initialize" do
    it "takes hash" do
      task.a.should == a
      task.b.should == b
    end
  end

  describe "invert_neg_rows" do
    let(:b) { Matrix.new_vector([-2, 4]).gsl_matrix }
    let(:task) { LinearTask.new(:a => a, :b => b) }

    let(:expected_a) { Matrix.new([-1, -1, -1, -1], [1, -1, 1, -2]) }
    let(:expected_b) { Matrix.new_vector([-2, 4]).gsl_matrix }
    it "changes signs of rows in A where b has negative item" do
      new_task = task.invert_neg_rows
      new_task.a.should == expected_a
      new_task.b.should == expected_b
    end
  end
end
