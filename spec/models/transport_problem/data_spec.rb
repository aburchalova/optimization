require 'spec_helper'

describe TransportProblem::Data do
  let(:a) { [1, 0] }
  let(:b) { [4, 5, 0] }
  let(:c) { Matrix.new([1, 2, 3], [4, 5, 6]) }
  let(:data) { TransportProblem::Data.new(a, b, c) }

  describe '#chomp!' do
    subject { data.chomp! }

    it 'removes rows and cols with zero a and b' do
      subject.a.should == [1]
      subject.b.should == [4, 5]
      subject.c.should == Matrix.new([1, 2])
    end
  end

  describe '#compatible?' do
    it { data.should be_compatible }
    it { data.with(:a => [-1, 1]).should_not be_compatible }
    it { data.with(:b => [-1, 1, -1]).should_not be_compatible }
  end
end
