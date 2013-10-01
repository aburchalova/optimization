require 'spec_helper'

describe BasisPlan do
  let(:plan) { BasisPlan.new :x => [1, 2, 3], :basis_indexes => [0] }
  let(:zero_plan) { BasisPlan.new :x => [0, 0, 0], :basis_indexes => [0] }

  it { plan.x_b.should == [1] }
  it { plan.x_n.should == [2, 3] }

  describe ".zero_x_n?" do 
    it { plan.zero_x_n?.should be_false }
    it { zero_plan.zero_x_n?.should be_true }
  end

  describe ".positive_x_b?" do
    it { plan.positive_x_b?.should be_true }
    it { zero_plan.positive_x_b?.should be_false }
  end
end