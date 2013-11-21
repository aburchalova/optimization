require 'spec_helper'

describe TransportProblem::CornerFirstPlan do
  let(:a) { [30, 40, 20] }
  let(:b) { [20, 30, 30, 10] }
  let(:data) { TransportProblem::Data.new(a, b) }
  let(:finder) { TransportProblem::CornerFirstPlan.new(data) }

  # describe '#find' do
  #   subject { finder.find }
  #   let(:chain) { Matrices::CellChain.new([[0, 0], [0, 1], [1, 1], [1, 2], [2, 2], [2, 3]]) }

  #   it 'calculates stepper stones' do
  #     subject.should == chain
  #   end
  # end

  let(:cell0) { Matrices::Cell.new([0, 0]) }
  let(:cell1) { Matrices::Cell.new([0, 1]) }

  describe '#update_to_next_cell' do    
    it 'chooses neighbour cell with least supplier/demand value' do
      finder.update_to_next_cell(cell0).should == [0, 1]
    end

    it 'subtracts from supplier when choosing supplier value' do

    end

    # it { finder.update_to_next_cell(cell1).should == [1, 1] }
  end

  describe '#update_result' do
    it 'assigns value to the cell' do
      finder.update_result(cell0, 5)
      finder.result.plan[cell0].should == 5
    end

    it 'adds cell to chain' do
      finder.update_result(cell0, 5)
      finder.result.chain.last.should == cell0
    end

    context 'after two steps' do
      it 'has chain of two cells' do
        finder.update_result(cell0, 5)
        finder.update_result(cell1, 7)

        finder.result.chain.should == [cell0, cell1]
      end
    end
  end
end
