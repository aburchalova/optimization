require 'spec_helper'

describe Tasks::Transport do
  context 'checking steps' do # see http://www.math-pr.com/tzd_3.php?B1=1&B2=1&A1=1&A2=1&P11=1&P12=1&P21=1&P22=1&StrPlan_Metod=1&max_line_a=2&max_coln_a=2&Number_form=0
    let(:a) { [1, 1] }
    let(:b) { [1, 1] }
    let(:c) { Matrix.ones(2, 2) }
    let(:data) { TransportProblem::Data.new(a, b, c) }

    let(:task) { Tasks::Transport.new(data, :method => :corner) }

    it 'is balanced' do
      task.should be_compatible
    end

    it 'adds 2 cells with min costs to basis' do
      task.basis_plan.basis.include?([0, 0]).should be_true
      task.basis_plan.basis.include?([1, 1]).should be_true
    end

    it 'adds costs to basis plan' do
      task.basis_plan[[0, 0]].should == 1
      task.basis_plan[[1, 1]].should == 1
    end

    it 'calculates suppliers potentials'
    it 'calculates consumers potentials'
    it 'is optimal'
  end
end
