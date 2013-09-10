require 'spec_helper'

shared_examples_for "optimization labs" do
  let(:matrix) { described_class.new([1, 2], [3, 4]) }


  describe ".eye_column" do
    context "when get column[1] of the square 2-matrix" do
      let(:index) { 1 }
      let(:matrix_size) { 2 }

      subject { described_class.eye_column(:size => matrix_size, :index => index) }

      it "has all zeros except 1st row" do
        ary = subject.to_a
        ary.delete_at(index)
        ary.should == [0]
      end

      it "has one on 1st row" do
        subject.to_a.delete_at(index).should == 1
      end

      it "is a column of size 2" do
        subject.size.should == 2
      end
    end
  end

  describe "#alpha" do
    let(:non_singular_matrix) { Matrix.new([6, 2], [4, 1]) }
    let(:non_singular_inversed_matrix) { non_singular_matrix.invert }

    context "when matrix is singular" do
      let(:matrix_different_by_0th_col) { Matrix.new([8, 2], [4, 1]) }
      subject { matrix_different_by_0th_col.alpha(non_singular_inversed_matrix, 0) }

      it { should be_zero }

    end

    context "when matrix is not singular" do
      let(:matrix_different_by_0th_col) { Matrix.new([7, 2], [4, 1]) }
      subject { matrix_different_by_0th_col.alpha(non_singular_inversed_matrix, 0) }

      it { should_not be_zero }
    end
  end
end
