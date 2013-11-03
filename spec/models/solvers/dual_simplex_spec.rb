require 'spec_helper'

describe Solvers::DualSimplex do
  # context "test1" do
  #   let(:a) { Matrix.new([1, 3, 1, 0, 0, 0], [2, 1, 0, 1, 0, 0], [0, 1, 0, 0, 1, 0], [3, 0, 0, 0, 0, 1]) }
  #   let(:b) { Matrix.new([18, 16, 5, 21]).transpose }
  #   let(:c) { Matrix.new_vector([2, 3, 0, 0, 0, 0]) }
  #   let(:basis) { [2, 3, 4, 5] }

  #   let(:dual_plan_vect) { Tasks::DualSimplex.first_basis_plan_for(a, b, c, basis) }
  #   let(:solver) { Solvers::DualSimplex.simple_init(a, b, c, dual_plan_vect, basis) }

  #   it { solver.result_ary.should == [6, 4, 0, 0, 1, 3] }
  # end

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

    end

  end
end
