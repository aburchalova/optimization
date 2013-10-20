require 'spec_helper'

describe FirstPhaseSimplexAnalyzer do
  let(:a) { Matrix.new([1, 2, 0, -2, 4], [0, -1, 1, 4, -1]) }
  let(:b) { Matrix.new_vector([2, 4]).gsl_matrix }
  let(:c) { Matrix.new_vector([2, 1, 3, 1, 6]) }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }

  subject(:analyzer) { FirstPhaseSimplexAnalyzer.new(task) }

  describe '#initialize' do
    it { analyzer.status.should be_initialized }
  end

  let(:opt_plan) do
    BasisPlan.new(Matrix.new_vector([2.0, 0.0, 4.0, 0.0, 0.0, 0.0, 0.0]), [0, 2])
  end
  before { analyzer.stub(:widened_optimal_plan => opt_plan) }

  describe "#compatible_constraints?" do
    it "is true if artificial vars sum == 0" do
      analyzer.compatible_constraints?.should == true
    end
  end

  describe "#widened_optimal_plan_basis" do
    it { analyzer.widened_optimal_plan_basis.should == [0, 2] }
  end

  describe "#prepare_working_task" do
    let(:b) { Matrix.new_vector([-2, 4]).gsl_matrix }
    it "inverts signs of rows" do
      task.should_receive(:invert_neg_rows)
      analyzer.prepare_working_task
    end
  end

  context "after composing working task" do

    before do
      analyzer.solve_artificial_task
      analyzer.prepare_working_task
    end

    describe "#analyze" do
      context "when no artificial indices in result basis" do
        let(:real_result_part) { [2.0, 0.0, 4.0, 0.0, 0.0] }
        let(:vector) { Matrix.new(real_result_part).transpose }
        it "takes part of artificial result" do
          analyzer.analyze
          analyzer.basis_plan.should == BasisPlan.new(vector, [0, 2])
        end
      end

      # let(:remover) { double(:ArtificialVariableRemover) } TODO: remove looping because of double doesn't do anything
      # it "calls artificial variable remover" do
      #   remover.stub(:try_remove => )
      #   ArtificialVariableRemover.should_receive(:new).with(analyzer).and_return remover
      #   remover.should_receive(:try_remove).and_return nil
      #   analyzer.analyze
      # end
    end
  end
end
