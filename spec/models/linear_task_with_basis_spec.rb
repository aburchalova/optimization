require 'spec_helper'

describe LinearTaskWithBasis do
  let(:a) { Matrix.new([1, 1, 1, 1], [1, -1, 1, -2]) }
  let(:b) { Matrix.new([2, 0]).transpose }
  let(:c) { Matrix.new([1, 2, 3, 4]) }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }

  let(:plan_vector) { Matrix.new([1, 1, 0, 0]).transpose }
  let(:x) { BasisPlan.new(plan_vector, [0, 1]) }

  let(:task_with_nonsingular_plan) { LinearTaskWithBasis.new(task, x) }

  describe ".plan?" do
    let(:not_plan_vector) { Matrix.new([1, 2, 0, 0]).transpose }
    let(:not_plan) { BasisPlan.new(not_plan_vector, []) }

    let(:wrong_size_plan) { BasisPlan.new(Matrix.new([1, 2, 0]).transpose, []) }

    let(:task_with_not_plan) { LinearTaskWithBasis.new(task, not_plan) }
    let(:task_with_wrong_size_vector) { LinearTaskWithBasis.new(task, wrong_size) }

    it { task_with_nonsingular_plan.plan?.should be_true }
    it { task_with_not_plan.plan?.should be_false }
    it { expect { task_with_wrong_size_vector.plan? }.to raise_error }
  end

  describe "basis_plan?" do
    let(:nonbasis_plan) { BasisPlan.new(plan_vector, [0, 1, 2]) }
    let(:task_with_non_basis_plan) { LinearTaskWithBasis.new(task, nonbasis_plan) }

    it { task_with_non_basis_plan.basis_plan?.should be_false }
    it { task_with_nonsingular_plan.basis_plan?.should be_true }
  end

  describe "nonsingular_plan?" do
    it { task_with_nonsingular_plan.nonsingular_plan?.should be_true }
  end

  describe "basis_matrix" do
    let(:expected) { Matrix.new([1, 1], [1, -1]) }
    it { task_with_nonsingular_plan.basis_matrix.should == expected }
  end

  describe "nonbasis_matrix" do
    let(:expected) { Matrix.new([1, 1], [1, -2]) }
    it { task_with_nonsingular_plan.nonbasis_matrix.should == expected }
  end

  describe "c_b" do
    let(:expected) { Matrix.new([1, 2]) }
    it { puts "task: #{task_with_nonsingular_plan}"; task_with_nonsingular_plan.c_b.should == expected }
  end

  describe "c_n" do
    let(:expected) { Matrix.new([3, 4]) }
    it { task_with_nonsingular_plan.c_n.should == expected }
  end

  describe "potential_string" do
    let(:expected) { GSL::Matrix[[3, -1]] }
    it { task_with_nonsingular_plan.potential_string.should == expected }
  end

  describe 'estimates_ary' do
    let(:expected) { [0, 0, -1, 1] }
    it { task_with_nonsingular_plan.estimates_ary.should == expected }
  end

  describe 'sufficient_for_optimal?' do
    it { task_with_nonsingular_plan.sufficient_for_optimal?.should == false }
  end

  describe 'negative_estimate_index' do
    it { task_with_nonsingular_plan.negative_estimate_index.should == 2 }
  end
end
