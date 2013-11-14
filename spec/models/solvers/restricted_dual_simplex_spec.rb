require 'spec_helper'

describe Solvers::RestrictedDualSimplex do
  context "testing jn+, jn- composing" do
    let(:a) { Matrix.new([1, 0, 0, 1, -3, 4, 0, 1, 4], [2, 1, 2, 1, -5, 2, 0, -5, 2], [1, 1, 1, 1, 1, 1, 1, 1, 1]) }
    let(:b) { Matrix.new([1, 8, 6]).transpose }
    let(:c) { Matrix.new_vector([-2, 2, 1, 3, 5, 10, 15, 4, 6]) }
    let(:basis) { [1, 2, 3] }
    let(:solver) { Solvers::RestrictedDualSimplex.simple_init(a, b, c, basis, :upper => 20) }

    it { solver.result_ary.should == [0, 0, 3.75, 0, 0, 0.25, 2, 0, 0] }
  end
end
