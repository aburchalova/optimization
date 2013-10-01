require 'spec_helper'

describe LinearTaskWithBasis do
  let(:a) { Matrix.new([1, 1, 1, 1], [1, -1, 1, -2]) }
  let(:b) { GSL::Matrix[[2, 0]].transpose }
  let(:task) { LinearTask.new(:a => a, :b => b) }

  let(:x) { GSL::Matrix[[1, 1, 0, 0]].transpose }
  let(:not_plan) { GSL::Matrix[[1, 2, 0, 0]].transpose }
  let(:wrong_size_plan) { GSL::Matrix[[1, 2, 0]].transpose }

  describe ".plan?" do 
    it { LinearTaskWithBasis.new(task, x).plan?.should be_true }
    it { LinearTaskWithBasis.new(task, not_plan).plan?.should be_false }
    it { expect { LinearTaskWithBasis.new(task, wrong_size).plan? }.to raise_error }
  end
end