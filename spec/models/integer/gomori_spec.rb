require 'spec_helper'

describe Integer::Gomori do
  context 'checking steps' do

    let(:a) { Matrix.new([7, 4, 1]) }
    let(:b) { Matrix.new([13]).transpose }
    let(:c) { Matrix.new_vector([21, 11, 0]) }
    let(:task) { LinearTask.new(a: a, b: b, c: c) }
    let(:solver) { Integer::Gomori.new(task) }

    it 'solves initial task' do
      solver.step
      solver.current_basis_plan.x_ary.should == [13.0/7, 0, 0]
      solver.current_basis_plan.basis_indexes.should == [0]
    end

    it 'finds correct basis matrix' do
      solver.step
      solver.current_task.a_b.to_a.should == [[7]]
      solver.a_b_inv.to_a.should == [[1.0/7]]
    end

    it 'finds nonint index' do
      solver.step
      solver.noninteger_natural_basis_idx.should == 0
    end

    it 'finds plane' do
      solver.step
      solver.y_string.to_a.flatten.should == [1.0/7]
    end

    it 'forms new restriction' do
      solver.step
      solver.new_linear_task.a.to_a.should == [[7, 4, 1, 0], [0, 4.0/7, 1.0/7, -1]]
      solver.new_linear_task.b.to_a.should == [[13], [6.0/7]]
    end

    context 'step 2' do
      before { 2.times { solver.step } }

      it 'basis matrix' do
        solver.current_task.a_b.to_a.should == [[7, 4], [0, 4.0/7]]
        solver.current_task.b.to_a.should == [[13], [6.0/7]]
      end

      it 'solution' do
        solver.current_basis_plan.x_ary.should == [1, 1.5, 0, 0]
        solver.current_basis_plan.basis_indexes.should == [0, 1]
      end
    end

    context 'iterate' do
      before { solver.iterate }

      it 'solves' do
        solver.current_basis_plan.x_ary.should == [0, 3, 1, 1, 0]
        (solver.current_basis_plan.basis_indexes - [1, 2, 3]).should == []
      end

      it 'cuts artificial' do
        solver.natural_result_ary.should == [0, 3, 1]
      end
    end

    context 'variant task' do
      let(:a) { Matrix.new(
        [0, 7, 1, -1, -4, 2, 4],
        [5, 1, 4, 3, -5, 2, 1],
        [2, 0, 3, 1, 0, 1, 5]
      ) }

      let(:b) { Matrix.new([12, 27, 19]).transpose }
      let(:c) { Matrix.new_vector([10, 2, 1, 7, 6, 3, 1]) }

      it 'ROCKS', :focus do
        solver.iterate
        solver.natural_result_ary.should == [5, 6, 0, 8, 6, 1, 0]
      end
    end

  end
end
