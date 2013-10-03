require 'spec_helper'

describe SimplexSolver do
  let(:a) { Matrix.new([1, 2, 0, -2, 4], [0, -1, 1, 4, -1]) }
  let(:b) { Matrix.new([2, 4]).transpose }
  let(:c) { Matrix.new([2, 1, 3, 1, 6]) }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }

  let(:plan_vector) { Matrix.new([2, 0, 4, 0, 0]).transpose }
  let(:basis) { [2, 0] }
  let(:x) { BasisPlan.new(plan_vector, basis) }
  let(:task_with_plan) { LinearTaskWithBasis.new(task, x) }

  subject(:solver) { SimplexSolver.new(task_with_plan) }

  describe "estimates_ary" do
    it { task_with_plan.estimates_ary.should == [0, 0, 0, 7, -1] }
  end

  describe 'theta' do
    it { task_with_plan.theta.should == [Float::INFINITY, 0.5] }
  end

  describe 'min_theta_with_index' do
    it { task_with_plan.min_theta_with_index.should == [0.5, 1] }
  end

  describe 'new_x' do
    it { solver.new_x.should == Matrix.new([0, 0, 4.5, 0, 0.5]).transpose }
  end

  describe 'new_basis' do
    it { solver.new_basis.should == [2, 4] }

    it 'doesnt change old basis' do
      solver.new_basis
      solver.task.basis_indexes.should == basis
    end

    it 'inserts new index on the place of old index' do
      new_col_index = solver.new_basis.index(solver.new_basis_column)
      gone_col_index = basis.index(solver.new_nonbasis_column)
      new_col_index.should == gone_col_index
    end
  end

  describe 'step' do
    it 'changes matrix' do
      solver.step
      solver.task.a_b.should == Matrix.new([0, 4], [1, -1])
      solver.task.a_b_inv.should == Matrix.new([0.25, 1], [0.25, 0]).gsl_matrix
    end

    it 'changes basis' do
      solver.step
      solver.task.basis_indexes.should == [2, 4]
    end

    it 'calculates new potentials' do
      solver.step
      solver.task.potential_string.should == GSL::Matrix[[9.0/4, 3]]
    end

    it 'sets "optimal" status when all estimates positive' do
      solver.iterate
      solver.task.estimates_ary.should == [ 0.25, 0.5, 0, 6.5, 0 ]
      solver.status.should == SimplexSolver::STATUSES[:optimal]
    end
  end
end
