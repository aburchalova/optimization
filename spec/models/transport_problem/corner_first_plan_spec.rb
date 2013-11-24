require 'spec_helper'

describe TransportProblem::CornerFirstPlan do
  let(:a) { [30, 40, 20] }
  let(:b) { [20, 30, 30, 10] }
  let(:data) { TransportProblem::Data.new(a, b) }
  let(:finder) { TransportProblem::CornerFirstPlan.new(data) }

  describe '#find' do
    let(:chain) { Matrices::CellSet.new([[0, 0], [0, 1], [1, 1], [1, 2], [2, 2], [2, 3]]) }

    it 'calculates stepper stones' do
      finder.find.basis.should == chain
    end
  end

  let(:cell0) { Matrices::Cell.new([0, 0]) }
  let(:cell1) { Matrices::Cell.new([0, 1]) }

  describe '#update_to_next_cell' do
    it 'chooses neighbour cell with least supplier/demand value' do
      finder.update_to_next_cell(cell0).should == cell1
    end

    it 'subtracts from supplier when choosing demand value' do
      finder.update_to_next_cell(cell0)
      finder.data.a.first.should == 10
    end

    context 'after first step' do
      before { finder.update_to_next_cell(cell0) }

      it 'subtracts from demand when choosing supplier value' do
        finder.update_to_next_cell(cell1)
        finder.data.b[1].should == 20
      end

      it { finder.update_to_next_cell(cell1).should == [1, 1] }

      it 'composes chain of two cells' do
        finder.update_to_next_cell(cell1)
        finder.result.basis.should == [cell0, cell1]
      end
    end
  end

  describe '#update_result' do
    it 'assigns value to the cell' do
      finder.update_result(cell0, 5)
      finder.result.plan[*cell0].should == 5
    end

    it 'adds cell to chain' do
      finder.update_result(cell0, 5)
      finder.result.basis.last.should == cell0
    end

    context 'after two steps' do
      it 'has chain of two cells' do
        finder.update_result(cell0, 5)
        finder.update_result(cell1, 7)

        finder.result.basis.should == [cell0, cell1]
      end
    end
  end
end
