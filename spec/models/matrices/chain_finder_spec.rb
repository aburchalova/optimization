require 'spec_helper'

describe Matrices::ChainFinder do

  context 'black box' do
    let(:cell_from) { Matrices::Cell.new([0, 0]) }
    let(:finder) { described_class.new(chains_set) }

    context 'two horizontal cells' do
      let(:cell_to) { cell_from.right }
      let(:chains_set) { [cell_to, cell_from] } # not equals result chain

      describe '#find' do
        subject { finder.find(cell_from, cell_to) }
        it { should == [cell_from, cell_to] }
      end
    end

    context 'two vertical cells' do
      let(:cell_to) { cell_from.down }
      let(:chains_set) { [cell_to, cell_from] }

      it { finder.find(cell_from, cell_to).should == [cell_from, cell_to] }
    end

    context 'right, down' do
      let(:cell2) { cell_from.right }
      let(:cell_to) { cell2.down }
      let(:chains_set) { [cell_to, cell2, cell_from] }

      it { finder.find(cell_from, cell_to).should == [cell_from, cell2, cell_to] }
    end

    context 'up, right' do
      let(:cell2) { cell_from.up }
      let(:cell_to) { cell2.right }
      let(:chains_set) { [cell_to, cell2, cell_from] }

      it { finder.find(cell_from, cell_to).should == [cell_from, cell2, cell_to] }
    end

    context 'when set contains cells that wont go in cycle: right right down' do
      let(:unused_cell) { cell_from.right }
      let(:cell2) { unused_cell.right }
      let(:cell_to) { cell2.down }
      let(:chains_set) { [cell_to, unused_cell, cell2, cell_from] }

      it 'doesnt include them' do
        finder.find(cell_from, cell_to).should == [cell_from, cell2, cell_to]
      end
    end

    context 'when start and end cycles cells are in same row' do
      let(:cell2) { cell_from.down }
      let(:cell3) { cell2.right }
      let(:cell_to) { cell3.up }
      let(:chains_set) { [cell3, cell_from, cell2, cell_to] }

      it 'returns shortest path' do
        finder.find(cell_from, cell_to).should == [cell_from, cell_to]
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
end
