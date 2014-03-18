require 'spec_helper'

describe Integer::Gomori do
  context 'checking variable removing' do

  end

  context 'checking steps' do

    let(:a) { Matrix.new([7, 4, 1]) }
    let(:b) { Matrix.new([13]).transpose }
    let(:c) { Matrix.new_vector([21, 11, 0]) }
    let(:task) { LinearTask.new(a: a, b: b, c: c) }
    let(:solver) { Integer::Gomori.new(task) }

    context 'checking steps' do
      before { stub_const('Float::COMPARISON_PRECISION', 0.01) }

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


      context 'task from practic' do
        let(:a) {
          Matrix.new(
            [-2, -1, 1, 0, 0],
            [3, 1, 0, 1, 0],
            [-1, 1, 0, 0, 1]
          )
        }

        let(:b) { Matrix.new([-1, 10, 3]).transpose }
        let(:c) { Matrix.new_vector([2, -5, 0, 0, 0]) }

        it 'step 1' do
          solver.step
          solver.current_basis_plan.x_ary.should == [3.333, 0, 5.667, 0, 6.333]
          # (solver.current_basis_plan.basis_indexes - [0, 2, 4]).should == []
          solver.current_basis_plan.basis_indexes.should == [0, 2, 4]
          solver.noninteger_natural_basis_idx.should == 0
          solver.noninteger_natural_basis_idx_basis_pos.should == 0
          solver.cutting_plane_values.last.should == 3.333
          solver.cutting_plane_values.should == [1, 0.333, 0, 0.333, 0, 3.333]
        end

        it 'step 2' do
          2.times { solver.step }
          solver.current_task.task.a.to_a.should == [
            [2, 1, -1, 0, 0, 0],
            [3, 1, 0, 1, 0, 0],
            [-1, 1, 0, 0, 1, 0],
            [0, 0.333, 0, 0.333, 0, -1]
          ]
          solver.current_basis_plan.x_ary.should == [3, 0, 5, 1, 6, 0]
        end

        it 'iterates' do
          solver.iterate
          solver.natural_result_ary.should == [3, 0, 5, 1, 6]
        end
      end

      context 'practic task 1' do
        let(:a) {
          Matrix.new(
            [5, -1, 1, 0, 0],
            [-1, 2, 0, 1, 0],
            [-7, 2, 0, 0, 1]
          )
        }

        let(:b) { Matrix.new([15, 6, 0]).transpose }
        let(:c) { Matrix.new_vector([-3.5, 1, 0, 0, 0]) }

        it 'step 1' do
          solver.step
          solver.current_basis_plan.x_ary.should == [1, 3.5, 13.5, 0, 0]
          solver.cutting_plane_values.should == [0, 1, 0, 0.58333, -0.08333, 3.5]
          solver.cutting_plane_fraction_values.should == [0, 0, 0, 0.58333, 0.917667, 0.5]
        end

        it 'step 2' do
          2.times { solver.step }
          solver.current_basis_plan.x_ary.should == [0.85714, 3, 13.71429, 0.85715, 0, 0]
        end

        it 'iterates' do
          solver.iterate
          solver.natural_result_ary.should == [0, 0, 15, 6, 0]
        end
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

      it 'ROCKS' do
        solver = Integer::Gomori.new(task, logging: true)
        solver.iterate
        solver.natural_result_ary.should == [5, 6, 0, 8, 6, 1, 0]
      end
    end

    context 'task for drawing' do
      let(:c) { Matrix.new_vector([21, 11]) }
      let(:b) { Matrix.new([13]).transpose }
      let(:a) { Matrix.new([7, 4]) }

      it 'solves', :focus do
        solver = Integer::Gomori.new(task, logging: true)
        solver.iterate
      end
    end

    context 'variants tasks' do
      # let(:solver) { Integer::Gomori.new(task, logging: true) }
      before {  solver.iterate }
      subject { solver.natural_result_ary }

      context 'task 1' do
        let(:a) {
          Matrix.new(
            [1, -5, 3, 1, 0, 0],
            [4, -1, 1, 0, 1, 0],
            [2, 4, 2, 0, 0, 1]
          )
        }
        let(:b) { Matrix.new([-8, 22, 30]).transpose }
        let(:c) { Matrix.new_vector([7, -2, 6, 0, 5, 2]) }

        it { should == [0, 2, 0, 2, 24, 22] }
      end

      context 'task 3' do
        let(:a) {
          Matrix.new(
            [1, 0, 0, 12, 1, -3, 4, -1],
            [0, 1, 0, 11, 12, 3, 5, 3],
            [0, 0, 1, 1, 0, 22, -2, 1]
          )
        }
        let(:b) { Matrix.new([40, 107, 61]).transpose }
        let(:c) { Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5]) }

        it { should == [77, 2, 5, 0, 0, 1, 0, 34] }
      end

      context 'task 5' do
        let(:a) {
          Matrix.new(
            [2, 1, -1, -3, 4, 7],
            [0, 1, 1, 1, 2, 4],
            [6, -3, -2, 1, 1, 1]
          )
        }
        let(:b) { Matrix.new([7, 16, 6]).transpose }
        let(:c) { Matrix.new_vector([1, 2, 1, -1, 2, 3]) }

        it { should == [5, 1, 11, 0, 0, 1] }
      end

      context 'task 7' do
        # before { stub_const('Float::COMPARISON_PRECISION', 0.0000001) }
        let(:a) {
          Matrix.new(
            [0, 7, -8, -1, 5, 2, 1],
            [3, 2, 1, -3, -1, 1, 0],
            [1, 5, 3, -1, -2, 1, 0],
            [1, 1, 1, 1, 1, 1, 1]
          )
        }
        let(:b) { Matrix.new([6, 3, 7, 7]).transpose }
        let(:c) { Matrix.new_vector([2, 9, 3, 5, 1, 2, 4]) }

        it { should == [1, 1, 1, 1, 1, 1, 1] }
      end

      context 'task 8' do
        let(:a) {
          Matrix.new(
            [1, 0, -1, 3, -2, 0, 1],
            [0, 2, 1, -1, 0, 3, -1],
            [1, 2, 1, 4, 2, 1, 1]
          )
        }
        let(:b) { Matrix.new([4, 8, 24]).transpose }
        let(:c) { Matrix.new_vector([-1, -3, -7, 0, -4, 0, -1]) }

        it { should == [1, 1, 0, 3, 3, 3, 0] }
      end
    end

    context 'tasks that need special precision' do
      before do
        stub_const('Float::COMPARISON_PRECISION', 0.0001)
        solver.iterate
      end

      subject { solver.natural_result_ary }

      # problem: when artificial tasker solves art task
      # minimal theta = 0.00..., e.g. zero
      # but when it's multiplied by step -- it becomes not zero
      # and when it's substracted from corr. x (zero), new x becomes < 0
      #
      # context 'task 2', :focus do
      #   let(:a) {
      #     Matrix.new(
      #       [1, -3, 2, 0, 1, -1, 4, -1, 0],
      #       [1, -1, 6, 1, 0, -2, 2, 2, 0],
      #       [2, 2, -1, 1, 0, -3, 8, -1, 1],
      #       [4, 1, 0, 0, 1, -1, 0, -1, 1],
      #       [1, 1, 1, 1, 1, 1, 1, 1, 1]
      #     )
      #   }
      #   let(:b) { Matrix.new([3, 9, 9, 5, 9]).transpose }
      #   let(:c) { Matrix.new_vector([-1, 5, -2, 4, 3, 1, 2, 8, 3]) }

      #   it { should == [1, 1, 1, 1, 1, 1, 1, 1, 1] }
      # end

      # context 'task 4', :focus do

      #   let(:a) {
      #     Matrix.new(
      #       [1, 2, 3, 12, 1, -3, 4, -1, 2, 3],
      #       [0, 2, 0, 11, 12, 3, 5, 3, 4, 5],
      #       [0, 0, 2, 1, 0, 22, -2, 1, 6, 7]
      #     )
      #   }
      #   let(:b) { Matrix.new([153, 123, 112]).transpose }
      #   let(:c) { Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5, 1, 2]) }

      #   it { should == [188, 0, 4, 0, 0, 3, 0, 38, 0, 0] }
      # end

      # context 'task 9' do
      #   let(:a) {
      #     Matrix.new(
      #       [1, -3, 2, 0, 1, -1, 4, -1, 0],
      #       [1, -1, 6, 1, 0, -2, 2, 2, 0],
      #       [2, 2, -1, 1, 0, -3, 2, -1, 1],
      #       [4, 1, 0, 0, 1, -1, 0, -1, 1],
      #       [1, 1, 1, 1, 1, 1, 1, 1, 1]
      #     )
      #   }
      #   let(:b) { Matrix.new([3, 9, 9, 5, 9]).transpose }
      #   let(:c) { Matrix.new_vector([-1, 5, -2, 4, 3, 1, 2, 8, 3]) }

      #   it { should == [0, 1, 1, 2, 0, 0, 1, 0, 4] }
      # end
    end



  end
end
