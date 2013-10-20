require 'spec_helper'

describe ArtificialTasker do
  let(:a) { Matrix.new([1, 2, 0, -2, 4], [0, -1, 1, 4, -1]) }
  let(:b) { Matrix.new_vector([2, 4]).gsl_matrix }
  let(:c) { Matrix.new_vector([2, 1, 3, 1, 6]) }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }

  let(:tasker) { ArtificialTasker.new(task) }

  describe "#task" do
    let(:new_width) { 7 }
    let(:widened_matrix) { Matrix.new([1, 2, 0, -2, 4, 1, 0], [0, -1, 1, 4, -1, 0, 1]) }

    subject(:new_task) { tasker.task }

    it "widens matrix" do
      new_task.a.should == widened_matrix
    end

    let(:widened_c) { Matrix.new_vector([0, 0, 0, 0, 0, -1, -1]) }
    it "widens c" do
      new_task.c.should == widened_c
    end
  end

  describe "#find_first_plan" do
    let(:expected_plan) { Matrix.new_vector([0, 0, 0, 0, 0, 2, 4]).gsl_matrix }
    let(:expected_basis) { [5, 6] }

    it "contains zeros on real variables and b coeffs on artificial" do
      tasker.find_first_plan.x.should == expected_plan
    end

    it "basis contains only artificial variables" do
      tasker.find_first_plan.basis_indexes.should == expected_basis
    end
  end

  describe "#solve" do
    let(:expected_result) { [2.0, 0.0, 4.0, 0.0, 0.0, 0.0, 0.0] }
    let(:result_plan) { tasker.solve.data }
    it { result_plan.x_ary == expected_result }
  end
end
