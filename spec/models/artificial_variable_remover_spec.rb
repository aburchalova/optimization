require 'spec_helper'

describe ArtificialVariableRemover do
  let(:a) { Matrix.new([1, 2, 0, -2, 4], [0, -1, 1, 4, -1]) }
  let(:b) { Matrix.new_vector([2, 4]).gsl_matrix }
  let(:c) { Matrix.new_vector([2, 1, 3, 1, 6]) }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }

  let(:analyzer) { FirstPhaseSimplexAnalyzer.new(task) }
  subject(:remover) { ArtificialVariableRemover.new(analyzer) }

  context "when no artificial indices in result basis" do
    before do
      analyzer.stub(:real_task_basis => [0, 2])
    end

    it "doesn't change basis" do
      remover.try_remove
      remover.real_task_basis.should == [0, 2]
    end

    it "doesn't remove constraints" do
      LinearConstraintRemover.should_not_receive(:new)
      remover.try_remove
    end
  end

  context "when artificial indices in result basis" do

    context "when linear dependend constraints" do
      let(:a) { Matrix.new([1, 2, 0], [1, 2, 0]) }
      let(:b) { Matrix.new_vector([2, 2]).gsl_matrix }
      let(:c) { Matrix.new_vector([2, 1, 3]) }
      let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }
      # let(:result_task) { LinearTask.new(:a => a, :b => b, :c => c) }

      # TODO: stub analyzer solver?
      # let(:wide_a) { Matrix.new([1, 2, 0, 1, 0], [1, 2, 0, 0, 1]) }
      # let(:wide_c) { Matrix.new_vector([0, 0, 0, -1, -1]) }
      # let(:real_task) { LinearTask.new(:a => wide_a, :b => b, :c => wide_c) }

      let(:analyzer) { FirstPhaseSimplexAnalyzer.new(task) }

      subject(:remover) { ArtificialVariableRemover.new(analyzer) }

      before do
        analyzer.solve_artificial_task
        analyzer.prepare_working_task
      end

      it "decreases basis size" do
        remover.try_remove
        remover.real_task_basis.length.should == 1
      end

      it "removes linear dependent constraint" do
        remover.try_remove
        analyzer.result_task.b.should == Matrix.new_vector([2]).gsl_matrix
      end

      it "leaves only real variables" do
        remover.try_remove
        analyzer.result_task.a.should == Matrix.new([1, 2, 0])
      end
    end
  end
end