require 'spec_helper'

describe Tasks::RestrictedDualSimplex do
  let(:a) do
    Matrix.new(
      [0, 1, 1, 2, 4, -1, 0],
      [0, 1, 0, -2, 0, -1, 1],
      [1, -1, 0, 1, 3, -1, 0]
    )
  end
  let(:b) { Matrix.new([-1, 2, -1]).transpose }
  let(:c) { Matrix.new_vector([1, -1, 1, 0, 2, -4, 1]) }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }
  let(:bas_ind) { [2, 6, 0] }
  let(:plan) { BasisPlan.simple_init([1, 1, 1], bas_ind) }
  subject(:dual_task) { Tasks::RestrictedDualSimplex.new(task, plan, :lower => 1, :upper => 10) }

  describe 'nonbasis_neg_est_idx' do
    it { dual_task.nonbasis_neg_est_idx.should == [] }
  end

  describe 'nonbasis_nonneg_est_idx' do
    it { dual_task.nonbasis_nonneg_est_idx.should == [1, 3, 4, 5] }
  end

  describe '.pseudoplan' do
    it { dual_task.pseudoplan.should == [-3, 1, -7, 1, 1, 1, 4] }
  end

  describe '#first_basis_plan_for' do
    subject { Tasks::RestrictedDualSimplex.first_basis_plan_for(a, b, c, bas_ind) }

    it 'takes potential vector' do
      should == plan
    end
  end

  describe 'unfit_kappa_index' do
    it 'takes kappa which has minimal variable number' do
      dual_task.unfit_kappa_index.should == 2
    end
  end

  describe 'unfit_step_weight' do
    it { dual_task.unfit_step_weight.should == 1 }

    context 'when unfit kappa is bigger than upper restriction ' do
      before do
        dual_task.stub(:pseudoplan => [100] * 7, :unfit_kappa_basis_var => 0)
      end

      it { dual_task.unfit_step_weight.should == -1 }
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

  describe 'has_step?' do
    it { dual_task.has_step?.should == true }
  end

  describe 'step' do
    it { dual_task.step.should == 1 }
  end

  describe 'step_index' do
    it { dual_task.step_index.should == 5 }
  end

  context 'when upper bound is infinite' do
    subject(:dual_task) { Tasks::RestrictedDualSimplex.new(task, plan, :lower => 1, :upper => Float::INFINITY) }

    it 'calculates the same step' do
      dual_task.step.should == 1
      dual_task.step_index.should == 5
    end

    describe 'steps_weight' do
      it { dual_task.steps_weight.to_a.flatten.values_at(1, 3, 4, 5).should == [-1, 1, 3, -1] }
    end

    context 'when negative estimates' do
      before do
        dual_task.stub(:coplan => Matrix.new_vector([-10] * 7))
      end

      it 'raises error' do
        expect { dual_task.pseudoplan }.to raise_error(ArgumentError)
      end
    end
  end
end
