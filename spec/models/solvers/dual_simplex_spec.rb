require 'spec_helper'

describe Solvers::DualSimplex do
  context "testing steps" do
    let(:a) do
      Matrix.new(
        [0, 1, 1, 2, 4, -1, 0],
        [0, 1, 0, -2, 0, -1, 1],
        [1, -1, 0, 1, 3, -1, 0]
      )
    end
    let(:b) { Matrix.new([-1, 2, -1]).transpose }
    let(:c) { Matrix.new_vector([1, -1, 1, 0, 2, -4, 1]) }
    let(:dual_plan_vect) { Matrix.new([1, 1, 1]).transpose }
    let(:basis) { [2, 6, 0] }
    let(:solver) { Solvers::DualSimplex.simple_init(a, b, c, basis) }

    context "1 step" do
      before { solver.step }

      it 'changes plan and status' do
        solver.task.x_ary.should == [1, 1, 2]
      end

      it 'changes status' do
        solver.status.should be_step_completed
      end

      let(:expected_basis_matrix) do
        Matrix.new(
          [1, 0, -1],
          [0, 1, -1],
          [0, 0, -1]
        ).gsl_matrix
      end

      it 'changes basis matrix' do
        solver.task.a_b.should == expected_basis_matrix
      end

      let(:expected_inv_basis_matrix) { expected_basis_matrix }
      it 'changes inverted basis matrix' do
        solver.task.a_b_inv.should == expected_inv_basis_matrix
      end
    end

    context 'when checking result' do
      before { solver.iterate }

      it 'calculates result for plain task' do
        plain_task = Tasks::Simplex.new(solver.task.task, solver.result_plan)
        plain_task.optimal_plan?.should be_true
      end
    end
  end

  context 'with RestrictedDualSimplex task' do

    context 'checking new task composing' do
      let(:a) do
        Matrix.new(
          [0, 1, 1, 2, 4, -1, 0],
          [0, 1, 0, -2, 0, -1, 1],
          [1, -1, 0, 1, 3, -1, 0]
        )
      end
      let(:b) { Matrix.new([-1, 2, -1]).transpose }
      let(:c) { Matrix.new_vector([1, -1, 1, 0, 2, -4, 1]) }
      let(:dual_plan_vect) { Matrix.new([1, 1, 1]).transpose }
      let(:basis) { [2, 6, 0] }

      let(:fake_dual_plan) { Tasks::RestrictedDualSimplex.first_basis_plan_for(a, b, c, basis) }

      let(:t) { LinearTask.new(:a => a, :b => b, :c => c) }
      let(:task_given_plan) { Tasks::RestrictedDualSimplex.new(t, BasisPlan.new(dual_plan_vect, basis)) }
      let(:task_calc_plan) { Tasks::RestrictedDualSimplex.new(t, fake_dual_plan) }

      let(:solver_given_plan) { Solvers::DualSimplex.new(task_given_plan) }
      let(:solver_calc_plan) { Solvers::DualSimplex.new(task_calc_plan) }
      it 'new plan calculated with delta is equal to new potential vector' do
        solver_given_plan.step
        solver_calc_plan.step

        solver_given_plan.task.plan.x.should == solver_calc_plan.task.plan.x
      end

      it 'plans are equal after 2 steps' do
        2.times { solver_given_plan.step; solver_calc_plan.step }

        solver_given_plan.task.plan.x.should == solver_calc_plan.task.plan.x
      end

      it 'solutions are equal' do
        solver_given_plan.result_plan.should == solver_calc_plan.result_plan
      end

      let(:task) { Tasks::DualSimplex.new(t, fake_dual_plan) }
      let(:solver) { Solvers::DualSimplex.new(task) }

      it 'solution is equal to one with DualTask' do
        solver.result_plan.should == solver_calc_plan.result_plan
      end
    end

    context 'black box testing' do
      context "test1" do
        let(:a) { Matrix.new([1, 3, 1, 0, 0, 0], [2, 1, 0, 1, 0, 0], [0, 1, 0, 0, 1, 0], [3, 0, 0, 0, 0, 1]) }
        let(:b) { Matrix.new([18, 16, 5, 21]).transpose }
        let(:c) { Matrix.new_vector([-2, -3, -1, -1, -1, -1]) }
        let(:plan_vector) { Matrix.new([0, 0, 18, 16, 5, 21]).transpose }
        let(:basis) { [3, 4, 5, 2] }
        let(:solver) { Solvers::DualSimplex.simple_init(a, b, c, basis, :upper => 100) }

        it { solver.result_ary.should == [6, 4, 0, 0, 1, 3] }
      end

      context "testing iterations and result" do
        let(:a) { Matrix.new([1, 3, -1, 0, 2, 0], [0, -2, 4, 1, 0, 0], [0, -4, 3, 0, 8, 1]) }
        let(:b) { Matrix.new([7, 12, 10]).transpose }
        let(:c) { Matrix.new_vector([0, -1, 3, 0, -2, 0]) }
        let(:plan_vector) { Matrix.new([7, 0, 0, 12, 0, 10]).transpose }
        let(:basis) { [0, 3, 5] }
        let(:solver) { Solvers::DualSimplex.simple_init(a, b, c, basis, :upper => 20) }

        it "1 step" do
          solver.step
          solver.task.basis_indexes.should == [1, 3, 5]
          solver.task.nonbasis_nonneg_est_idx.should == [4]
          solver.task.nonbasis_neg_est_idx.should == [0, 2]
          solver.task.basis_matrix.should == Matrix.new([3, 0, 0], [-2, 1, 0], [-4, 0, 1])
        end

        it '2 steps' do
          2.times { solver.step }
          solver.task.basis_indexes.should == [1, 0, 5]
          solver.task.nonbasis_nonneg_est_idx.should == [3, 4]
          solver.task.nonbasis_neg_est_idx.should == [2]
        end

        it { solver.result_ary.should == [0, 4, 5, 0, 0, 11] }

        context 'testing incompatible constraints' do
          before do
            solver.task.stub(:steps => Array.new(6, Float::INFINITY))
          end

          it { solver.result.should be_incompatible }
        end
      end

      context 'simple example' do
        let(:a) { Matrix.new([1, -1, 3, -2], [1, -5, 11, -6]) }
        let(:b) { Matrix.new([1, 9]).transpose }
        let(:c) { Matrix.new_vector([1, 1, -2, -3]) }
        let(:basis) { [0, 1] }

        let(:solver) { Solvers::DualSimplex.simple_init(a, b, c, basis, :lower => [0, 0, 2, 3], :upper => [1, 2, 3, 6]) }

        it "solves" do
          solver.result_ary.should == [0, 0, 3, 4]
        end
      end

      context "class task2" do
        let(:a) { Matrix.new([2, 0, 1, -1, 0, 1, 1, -2, 0], [-1, 3, 1, -1, 1, 2, 0, 4, 0], [0, 4, 2, 0, 0, 1, 0, 5, 1]) }
        let(:b) { Matrix.new([4, 3, 5]).transpose }
        let(:c) { Matrix.new_vector([-4, 2, 1, -2, 0, 3, 2, -1, 0]) }
        let(:plan_vector) { Matrix.new([0, 0, 0, 0, 3, 0, 4, 0, 5]).transpose }
        let(:basis) { [4, 6, 8] }
        let(:solver) { Solvers::DualSimplex.simple_init(a, b, c, basis, :upper => 5) }

        it { solver.result_ary.should == [0, 0, 0, 5, 0, 4, 5, 0, 1] }

        context 'when high upper restriction' do
          let(:solver) { Solvers::DualSimplex.simple_init(a, b, c, basis, :upper => 5000) }
          it "result is optimal for plain task" do
            solver.iterate
            solver.check_result.should be_true
          end
        end
      end
    end

  end
end
