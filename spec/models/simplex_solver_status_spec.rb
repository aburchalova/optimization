require 'spec_helper'

describe SimplexSolverStatus do

  describe '#from_code' do

    it 'initializes from common codes' do
      expected = SimplexSolverStatus::STATUSES[:initialized]
      SimplexSolverStatus.from_code(:initialized).description.should == expected
    end

    it 'initializes from any code' do
      expected = "Blah blah"
      SimplexSolverStatus.from_code(:blah_blah).description.should == expected
    end
  end

  context "on question methods" do
    subject { SimplexSolverStatus.from_code(:initialized) }

    it { should be_initialized }
    it { should_not be_optimal }
    it { should_not be_finished }
    it { should_not be_step_completed }
  end

  context "on bang methods" do
    subject(:status) { SimplexSolverStatus.from_code(:initialized) }

    it "changes code and description" do
      status.step_completed!
      status.should be_step_completed
    end

    it "makes data blank" do
      status.not_a_plan!
      status.data.should be_blank
    end
  end
end