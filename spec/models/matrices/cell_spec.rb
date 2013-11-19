require 'spec_helper'

describe Matrices::Cell do
  subject { Matrices::Cell.new([1, 2]) }

  it 'is indexed as array' do
    subject[0].should == 1
    subject[1].should == 2
  end

  it 'has row and column' do
    subject.row.should == 1
    subject.column.should == 2
  end

  describe '#share_item?' do
    context 'when two cells in the same row' do
      let(:another) { Matrices::Cell.new([1, 3]) }

      it { subject.should be_share_item(another)}
    end

    context 'when two cells in the same column' do
      let(:another) { Matrices::Cell.new([5, 2]) }

      it { subject.should be_share_item(another)}
    end

    context 'when first cells row is equal another cells column' do
      let(:another) { Matrices::Cell.new([2, 1]) }

      it { subject.should_not be_share_item(another)}
    end

    context 'when two cells in different row and column' do
      let(:another) { Matrices::Cell.new([5, 7]) }

      it { subject.should_not be_share_item(another)}
    end
  end
end
