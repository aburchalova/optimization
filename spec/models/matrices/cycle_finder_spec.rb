require 'spec_helper'

describe Matrices::CycleFinder do
    let(:cell_from) { Matrices::Cell.new([0, 0]) }
    let(:finder) { described_class.new(chains_set) }
  context 'when chain but no cycle' do
      let(:cell2) { cell_from.down }
      let(:cell_to) { cell2.right }
      let(:chains_set) { [cell_to, cell_from, cell2] }

      it 'returns nil' do
        finder.find(cell_from, cell_to).should == nil
      end
  end

   context 'when start and end cycles cells are in same row' do
      let(:cell2) { cell_from.down }
      let(:cell3) { cell2.right }
      let(:cell_to) { cell3.up }
      let(:chains_set) { [cell3, cell_from, cell2, cell_to] }

      it 'composes cycle of 4 items ' do
        finder.find(cell_from, cell_to).should == [cell_from, cell2, cell3, cell_to]
      end
    end

    context 'when start and end cycles cells are in same column' do
      let(:cell2) { cell_from.right }
      let(:cell3) { cell2.down }
      let(:cell_to) { cell3.left }
      let(:chains_set) { [cell3, cell_from, cell2, cell_to] }

      it 'composes cycle of 4 items ?' do
        finder.find(cell_from, cell_to).should == [cell_from, cell2, cell3, cell_to]
      end
    end
end
