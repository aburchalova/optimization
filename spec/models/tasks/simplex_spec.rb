require 'spec_helper'

describe Tasks::Simplex do
  let(:a) { Matrix.new([1, 1, 1, 1], [1, -1, 1, -2]) }
  let(:b) { Matrix.new([2, 0]).transpose }
  let(:c) { Matrix.new_vector([1, 2, 3, 4]) }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }

  let(:plan_vector) { Matrix.new([1, 1, 0, 0]).transpose }
  let(:x) { BasisPlan.new(plan_vector, [0, 1]) }

  let(:task_with_nonsingular_plan) { Tasks::Simplex.new(task, x) }

  describe ".plan?" do
    let(:not_plan_vector) { Matrix.new([1, 2, 0, 0]).transpose }
    let(:not_plan) { BasisPlan.new(not_plan_vector, []) }

    let(:wrong_size_plan) { BasisPlan.new(Matrix.new([1, 2, 0]).transpose, []) }

    let(:task_with_not_plan) { Tasks::Simplex.new(task, not_plan) }
    let(:task_with_wrong_size_vector) { Tasks::Simplex.new(task, wrong_size) }

    it { task_with_nonsingular_plan.plan?.should be_true }
    it { task_with_not_plan.plan?.should be_false }
    it { expect { task_with_wrong_size_vector.plan? }.to raise_error }
  end

  describe "basis_plan?" do
    let(:nonbasis_plan) { BasisPlan.new(plan_vector, [0, 1, 2]) }
    let(:task_with_non_basis_plan) { Tasks::Simplex.new(task, nonbasis_plan) }

    it { task_with_non_basis_plan.basis_plan?.should be_false }
    it { task_with_nonsingular_plan.basis_plan?.should be_true }
  end

  describe "nonsingular_plan?" do
    it { task_with_nonsingular_plan.nonsingular_plan?.should be_true }
  end

  describe "basis_matrix" do
    let(:expected) { Matrix.new([1, 1], [1, -1]) }
    it { task_with_nonsingular_plan.basis_matrix.should == expected }
  end

  describe "nonbasis_matrix" do
    let(:expected) { Matrix.new([1, 1], [1, -2]) }
    it { task_with_nonsingular_plan.nonbasis_matrix.should == expected }
  end

  describe "c_b" do
    let(:expected) { Matrix.new([1], [2]) }
    it { task_with_nonsingular_plan.c_b.should == expected }
  end

  describe "c_n" do
    let(:expected) { Matrix.new([3], [4]) }
    it { task_with_nonsingular_plan.c_n.should == expected }
  end

  describe "potential_string" do
    let(:expected) { GSL::Matrix[[1.5, -0.5]] }
    it { task_with_nonsingular_plan.potential_string.should == expected }
  end

  describe 'estimates_ary' do
    let(:expected) { [0, 0, -2, -1.5] }
    it { task_with_nonsingular_plan.estimates_ary.should == expected }
  end

  describe 'sufficient_for_optimal?' do
    it { task_with_nonsingular_plan.sufficient_for_optimal?.should == false }
  end

  describe 'negative_estimate_index' do
    it { task_with_nonsingular_plan.negative_estimate_index.should == 2 }
  end

  describe 'inverted_basis_matrix' do
    let(:a_b_inverted_expected) { task_with_nonsingular_plan.a_b.invert }

    it "is retrieved by z calculations" do
      task_with_nonsingular_plan.should_receive(:inverted_basis_matrix).and_return a_b_inverted_expected
      task_with_nonsingular_plan.z
    end

    it "if forced set, doesn't calculate" do
      task_with_nonsingular_plan.inverted_basis_matrix = a_b_inverted_expected
      task_with_nonsingular_plan.a_b.should_not_receive(:invert) #invert is standart and 'slow'

      task_with_nonsingular_plan.z #retrieves inverted_basis_matrix
    end
  end

  # describe '#target_function_delta' do
  #   let(:old_plan) { BasisPlan.new(Matrix.new([1, 2, 0, 0]).transpose, [0, 1]) }
  #   let(:new_plan) { BasisPlan.new(Matrix.new([0, 4, 3, 0]).transpose, [2, 1]) }
  #   let(:old_task) { Tasks::Simplex.new(task, old_plan) }
  #   let(:new_task) { Tasks::Simplex.new(task, new_plan) }

  #   it 'calculates target funcion change', :focus do
  #     old_target = old_task.target_function
  #     new_target = new_task.target_function
  #     old_task.target_function_delta(new_plan.x).should == new_target - old_target
  #   end
    
  # end

  context "when testing sign restrictions" do
    let(:t) { task_with_nonsingular_plan }

    describe 'lower_sign_restriction_apply?' do
      let(:task1) { t.with_restrictions(:lower => [1, 1, 1, 0]) }
      it { task1.lower_sign_restriction_apply?.should be_false }

      let(:task2) { t.with_restrictions(:lower => [1, 1, 0, 0]) }
      it { task2.lower_sign_restriction_apply?.should be_true }
    end

    describe 'upper_sign_restriction_apply?' do
      let(:task1) { t.with_restrictions(:upper => [1, 1, 1, 0]) }
      it { task1.upper_sign_restriction_apply?.should be_true }

      let(:task2) { t.with_restrictions(:upper => [1, 0, 0, 0]) }
      it { task2.upper_sign_restriction_apply?.should be_false }
    end

    describe 'sign_restrictions_apply?' do
      let(:task1) { t.with_restrictions(:lower => [1, 1, 0, 0], :upper => [1, 1, 1, 0]) }
      it { task1.upper_sign_restriction_apply?.should be_true }

      let(:task2) { t.with_restrictions(:lower => [1, 1, 0, 0], :upper => [1, 0, 0, 0]) }
      it { task2.upper_sign_restriction_apply?.should be_false }
    end
  end
end
