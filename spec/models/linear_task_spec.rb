require 'spec_helper'

describe 'LinearTask' do
  let(:a) { Matrix.new([1, 1, 1, 1], [1, -1, 1, -2]) }
  let(:b) { GSL::Matrix[[2, 0]].transpose }
  let(:task) { LinearTask.new(:a => a, :b => b) }
  
  describe ".initialize" do
    it "takes hash" do
      task.a.should == a
      task.b.should == b
    end
  end
end
