require 'spec_helper'

describe FirstPhaseSimplexAnalyzer do
  let(:a) { Matrix.new([1, 2, 0, -2, 4], [0, -1, 1, 4, -1]) }
  let(:b) { Matrix.new_vector([2, 4]).gsl_matrix }
  let(:c) { Matrix.new_vector([2, 1, 3, 1, 6]) }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }

  subject(:analyzer) { FirstPhaseSimplexAnalyzer.new(task) }
  it { analyzer.status.should be_initialized }

  describe "#artificial_task" do
    let(:new_width) { 7 }
    let(:widened_matrix) { Matrix.new([1, 2, 0, -2, 4, 1, 0], [0, -1, 1, 4, -1, 0, 1]) }

    subject(:new_task) { analyzer.artificial_task }

    it "widens matrix" do
      new_task.a.should == widened_matrix
    end

    let(:widened_c) { Matrix.new_vector([0, 0, 0, 0, 0, -1, -1]) }
    it "widens c" do
      new_task.c.should == widened_c
    end
  end

  describe "#artificial_plan" do
    let(:expected_plan) { Matrix.new_vector([0, 0, 0, 0, 0, 2, 4]).gsl_matrix }
    let(:expected_basis) { [5, 6] }

    it "contains zeros on real variables and b coeffs on artificial" do
      analyzer.artificial_plan.x.should == expected_plan
    end

    it "basis contains only artificial variables" do
      analyzer.artificial_plan.basis_indexes.should == expected_basis
    end
  end

  describe "#artificial_task_result" do
    let(:expected_result) { [2.0, 0.0, 4.0, 0.0, 0.0, 0.0, 0.0] }
    it { analyzer.artificial_task_result.should == expected_result }
  end

  describe "#initial_task_has_plan?" do
    it("is true if artificial vars sum == 0") { analyzer.initial_task_has_plan?.should == true }
  end

  describe "#artificial_task_result_basis" do
    it { analyzer.artificial_task_result_basis.should == [0, 2] }
  end

  describe "#initial_task_basis_plan" do
    context "when no artificial indices in result basis" do
      let(:real_result_part) { [2.0, 0.0, 4.0, 0.0, 0.0] }

      it "takes part of artificial result" do
        analyzer.initial_task_basis_plan.should == BasisPlan.new(real_result_part, [0, 2])
      end
    end

    context "when artificial indices in result basis" do
      context "when no linear dependend constraints" do
        it "removes artificial vars"
      end

      context "when linear dependend constraints" do
        let(:a) { Matrix.new([1, 2, 0, -2, 4], [1, 2, 0, -2, 4], [1, 1, 1, 1, 1]) }
        let(:b) { Matrix.new_vector([2, 2, 1]).gsl_matrix }
        let(:c) { Matrix.new_vector([2, 1, 3, 1, 6, 1]) }
        let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }
        subject(:analyzer) { FirstPhaseSimplexAnalyzer.new(task) }

        it "decreases basis size" do
          analyzer.initial_task_basis_plan.basis_indexes.length.should == 2
        end

        it "removes linear dependent constraint" do
          analyzer.initial_task_basis_plan
          analyzer.result_task.b.should == Matrix.new_vector([2, 1]).gsl_matrix
        end

        it "leaves only real variables" do
          analyzer.initial_task_basis_plan
          analyzer.result_task.a.should == Matrix.new([1, 2, 0, -2, 4], [1, 1, 1, 1, 1])
        end
      end
    end
  end

  describe "#analyze" do

  end
end
