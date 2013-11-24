require 'spec_helper'

describe Matrices::CellSet do
  let(:with_cycle) { Matrices::CellSet.new(   [ [1, 0], [2, 0], [2, 1], [0, 1], [0, 2], [2, 2]  ]) }
  let(:without_cycle) { Matrices::CellSet.new([ [1, 0], [2, 0], [2, 1], [0, 1], [0, 2]          ]) }

  describe '#has_row_neighbours?' do
    subject { with_cycle }

    it { subject.has_row_neighbours?( subject[1] ).should be_true }
    it { subject.has_row_neighbours?( subject[0] ).should be_false }
  end

  describe '#remove_rows_with_1_item!' do
    subject { with_cycle }
    let(:removed) { Matrices::CellSet.new([[2, 0], [2, 1], [0, 1], [0, 2], [2, 2]]) }

    it 'removes second row' do
      subject.remove_rows_with_1_item!

      subject.should == removed
    end

    it 'returns true if rows were deleted' do
      subject.remove_rows_with_1_item!.should be_true
    end

    it 'returns false if no rows were deleted' do
      subject.remove_rows_with_1_item!
      subject.remove_rows_with_1_item!.should be_false
    end
  end

  describe '#has_column_neighbours?' do
    subject { without_cycle }

    it { subject.has_column_neighbours?( subject.first ).should be_true }
    it { subject.has_column_neighbours?( subject.last ).should be_false }
  end

  describe '#remove_columns_with_1_item!' do
    subject { without_cycle }
    let(:removed) { Matrices::CellSet.new([[1, 0], [2, 0], [2, 1], [0, 1]]) }

    it 'removes third column' do
      subject.remove_columns_with_1_item!

      subject.should == removed
    end

    it 'returns true if columns were deleted' do
      subject.remove_columns_with_1_item!.should be_true
    end

    it 'returns false if no columns were deleted' do
      subject.remove_columns_with_1_item!
      subject.remove_columns_with_1_item!.should be_false
    end
  end

  describe '#remove_rows_and_cols_with_1_item!' do
    context 'when no cycle' do
      subject { without_cycle }

      it 'leaves empty chain' do
        subject.remove_rows_and_cols_with_1_item!
        subject.should be_empty
      end
    end

    context 'when cycle' do
      subject { with_cycle }
      let(:removed) { Matrices::CellSet.new([ [2, 1], [0, 1], [0, 2], [2, 2] ]) }

      it 'chain has items' do
        subject.remove_rows_and_cols_with_1_item!

        subject.should == removed
      end
    end
  end

  describe '#has_cycle?' do
    it { with_cycle.should be_has_cycle  }
    it { without_cycle.should_not be_has_cycle  }
  end

  describe '#clone' do
    subject { without_cycle }

    it 'returns brand new chain' do
      clone = subject.clone
      clone << [5, 5]
      clone.should_not == subject
    end

    it 'returns chain with the same items' do
      clone = subject.clone
      clone.first.should == subject.first
    end
  end

  describe '#extract_cycle' do
    let(:cycle) { [ [2, 1], [0, 1], [0, 2], [2, 2] ] }

    it { with_cycle.extract_cycle([2, 1].to_c, [2, 2].to_c).should == cycle }
  end

  let(:cell1) { Matrices::Cell.new([2, 0]) }
  let(:row_neighbours) { [Matrices::Cell.new([2, 1]), Matrices::Cell.new([2, 2])] }
  describe '#all_row_neighbours' do
    it { with_cycle.all_row_neighbours(cell1).should == row_neighbours }
  end
end
