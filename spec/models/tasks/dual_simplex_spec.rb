require 'spec_helper'

describe Tasks::DualSimplex do
  let(:a) do
    Matrix.new(
      [0, 1, 1, 2, 4, -1, 0],
      [0, 1, 0, -2, 0, -1, 1],
      [1, -1, 0, 1, 3, -1, 0]
    )
  end
  let(:b) { Matrix.new([-1, 2, -1]).transpose }
  let(:c) { Matrix.new([1, -1, 1, 0, 2, -4, 1]).transpose }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }
  let(:bas_ind) { [2, 6, 0] }
  let(:plan) { BasisPlan.simple_init([1, 1, 1], bas_ind) }
  subject(:dual_task) { Tasks::DualSimplex.new(task, plan) }

  describe '.plan?' do
    it { dual_task.plan?.should be_true }

    let(:not_plan) { BasisPlan.simple_init([1, 1, 5], [2, 6, 1]) }
    it { Tasks::DualSimplex.new(task, not_plan).plan?.should be_false }
  end

  describe '.basis_plan?' do
    it { dual_task.basis_plan?.should be_true }
  end

  describe '.kappa_b' do
    it { dual_task.kappa_b.to_a.flatten.should == [-1, 2, -1] }
  end

  describe '.pseudoplan' do
    let(:kappa_b) { Matrix.new([1, 2, 3]).transpose }
    before { dual_task.stub(:pseudoplan_b => kappa_b) }

    it 'sets values according to basis indices' do
      res = dual_task.pseudoplan.to_a.flatten
      # see plan basis indices, on the 0th pos is 2
      res[2].should == kappa_b[0]
      res[6].should == kappa_b[1]
      res[0].should == kappa_b[2]
    end

    it 'sets nonbasis items to 0' do
      dual_task.pseudoplan.to_a.flatten.values_at(1, 3, 4, 5).all?(&:zero?).should be_true
    end
  end

  describe 'neg_kappa_index' do
    let(:kappa_b) { Matrix.new([-1, -1, -1]).transpose }
    before { dual_task.stub(:pseudoplan_b => kappa_b) }

    it 'takes kappa which has minimal variable number' do
      dual_task.neg_kappa_index.should == 2
    end
  end

  describe 'step_multiplier_string' do
    it { dual_task.step_multiplier_string.to_a.flatten.should == [0, 0, 1] }
  end

  describe 'steps_weight' do
    subject(:mu) { dual_task.steps_weight.to_a.flatten }

    it 'calculates non-basis' do
      mu.values_at(1, 3, 4, 5).should == [-1, 1, 3, -1]
    end

    it 'sets 1 on variable with negative kappa index' do
      mu[bas_ind[2]].should == 1
    end

    it 'sets 0 on basis variables but one with negative kappa index' do
      mu[bas_ind[0]].should == 0
      mu[bas_ind[1]].should == 0
    end
  end

  describe '.steps' do
    let(:inf) { Float::INFINITY }
    subject(:steps) { dual_task.steps }

    it 'is calculated for non-basis indices' do
      steps.values_at(1, 3, 4, 5).should == [2, inf, inf, 1]
    end

    it 'is infinity for basis indices' do
      steps.values_at(2, 6, 0).should == [inf, inf, inf]
    end
  end
end
