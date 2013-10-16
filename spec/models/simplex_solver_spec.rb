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

  describe 'min_theta' do
    it { task_with_plan.min_theta.should == 0.5 }
  end

  describe 'min_theta_index' do
    it { task_with_plan.min_theta_index.should == 1 }

    context "when Blend's rule counts" do
      before do
        task_with_plan.stub(:theta =>  [42, 42, Float::INFINITY])
        task_with_plan.stub(:basis_indexes => [9, 8, 7])
      end

      it "takes value from min thetas with index s so that basis_indexes[s] is minimal" do
        task_with_plan.min_theta_index.should == 1
      end
    end
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
      solver.status.should be_optimal
    end
  end

  context "when testing black box" do
    context "test1" do
      let(:a) { Matrix.new([1, 3, 1, 0, 0, 0], [2, 1, 0, 1, 0, 0], [0, 1, 0, 0, 1, 0], [3, 0, 0, 0, 0, 1]) }
      let(:b) { Matrix.new([18, 16, 5, 21]).transpose }
      let(:c) { Matrix.new([2, 3, 0, 0, 0, 0]) }
      let(:plan_vector) { Matrix.new([0, 0, 18, 16, 5, 21]).transpose }
      let(:basis) { [2, 3, 4, 5] }
      let(:solver) { SimplexSolver.simple_init(a, b, c, plan_vector, basis) }

      it { solver.result.should == [6, 4, 0, 0, 1, 3] }
    end

    context "test not a plan" do
      let(:a) { Matrix.new([1, 0, 7.0/5, 0], [0, 1, -13.0/5, 2]) }
      let(:b) { Matrix.new([-1, 0]).transpose }
      let(:c) { Matrix.new([-4, -2, 1, -1]) } # ???
      let(:plan_vector) { Matrix.new([-1, 0, 0, 0]).transpose }
      let(:basis) { [0, 1] }
      let(:solver) { SimplexSolver.simple_init(a, b, c, plan_vector, basis) }

      it { solver.result.should be_not_a_plan }
    end

    context "test3" do
      let(:a) { Matrix.new([1, 3, -1, 0, 2, 0], [0, -2, 4, 1, 0, 0], [0, -4, 3, 0, 8, 1]) }
      let(:b) { Matrix.new([7, 12, 10]).transpose }
      let(:c) { Matrix.new([0, -1, 3, 0, -2, 0]) } # ???
      let(:plan_vector) { Matrix.new([7, 0, 0, 12, 0, 10]).transpose }
      let(:basis) { [0, 3, 5] }
      let(:solver) { SimplexSolver.simple_init(a, b, c, plan_vector, basis) }

      it { solver.result.should == [0, 4, 5, 0, 0, 11] }
    end
    # TODO: more tests

    context "class task1" do
      let(:a) { Matrix.new([1, 0, 0, 1, -3, 4, 0, 1, 4], [2, 1, 2, 1, -5, 2, 0, -5, 2], [1, 1, 1, 1, 1, 1, 1, 1, 1]) }
      let(:b) { Matrix.new([1, 8, 6]).transpose }
      let(:c) { Matrix.new([-2, 2, 1, 3, 5, 10, 15, 4, 6]) }
      let(:plan_vector) { Matrix.new([0, 3, 2, 1, 0, 0, 0, 0, 0]).transpose }
      let(:basis) { [1, 2, 3] }
      let(:solver) { SimplexSolver.simple_init(a, b, c, plan_vector, basis) }

      it { solver.result.should == [0, 0, 3.75, 0, 0, 0.25, 2, 0, 0] }
    end

    context "class task2" do
      let(:a) { Matrix.new([2, 0, 1, -1, 0, 1, 1, -2, 0], [-1, 3, 1, -1, 1, 2, 0, 4, 0], [0, 4, 2, 0, 0, 1, 0, 5, 1]) }
      let(:b) { Matrix.new([4, 3, 5]).transpose }
      let(:c) { Matrix.new([4, 2, 1, -2, 0, 3, 2, -1, 0]) }
      let(:plan_vector) { Matrix.new([0, 0, 0, 0, 3, 0, 4, 0, 5]).transpose }
      let(:basis) { [4, 6, 8] }
      let(:solver) { SimplexSolver.simple_init(a, b, c, plan_vector, basis) }

      it { solver.result.should == [2, 0, 0, 5, 0, 5, 0, 0, 0] }
    end
  end
end
