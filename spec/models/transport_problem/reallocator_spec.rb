require 'spec_helper'

describe TransportProblem::Reallocator do
  let(:basis) do
    Matrices::CellSet.new([
                            [0, 0], [0, 4],
                            [1, 1], [1, 2],
                            [2, 0], [2, 3], [2, 5],
                            [3, 1],
                            [4, 1], [4, 3]
    ])
  end
  let(:plan) { Matrix.from_gsl(Matrix.ones(5, 6)) }
  let(:basis_plan) { TransportProblem::BasisPlan.new(plan, basis) }
  let(:nonbasis_cell) { Matrices::Cell.new([0, 1]) }

  subject(:reallocator) { described_class.new(basis_plan, nonbasis_cell) }

  describe '#cycle' do
    it { reallocator.cycle.equal_items?([[0, 1], [0, 0], [2, 0], [2, 3], [4, 3], [4, 1]]).should be_true }
  end

  describe '#mark' do
    let(:u_plus) { reallocator.mark.first }
    let(:u_minus) { reallocator.mark.last }

    it 'marks as plus' do
      u_plus.equal_items?([[0, 1], [4, 3], [2, 0]]).should be_true
    end

    it 'marks as minus' do
      u_minus.equal_items?([[0, 0], [2, 3], [4, 1]]).should be_true
    end
  end

  describe '#reallocation_value_idx' do
    let(:plan) { Matrix.new([4, 2, 5, 0]) }
    let(:basis_plan) { TransportProblem::BasisPlan.new(plan) }
    let(:search_cells) { Matrices::CellSet.new([[0, 0], [0, 1], [0, 2]]) }
    subject(:reallocator) { described_class.new(basis_plan, nonbasis_cell) }

    it 'takes minimal value of cells' do
      reallocator.reallocation_value_idx(search_cells).should == [0, 1]
    end

    context 'when more than one minimal value' do
      let(:plan) { Matrix.new([4, 2, 2, 0]) }
      let(:search_cells) { Matrices::CellSet.new([[0, 2], [0, 0], [0, 1]]) }

      it 'takes one thats first if order matrix by flattened rows' do
        reallocator.reallocation_value_idx(search_cells).should == [0, 1]
      end
    end
  end

  describe '#reallocation_value' do
    let(:u_minus) { Matrices::CellSet.new([[0, 0], [2, 3], [4, 1]]) }
    it { reallocator.reallocation_value(u_minus).should == 1 }
  end

  describe '#reallocate' do
    subject(:new_basis_plan) { reallocator.reallocate }

    it 'doesnt touch nonbasis cells except starting' do
      new_basis_plan[[0, 2]].should == 1
    end

    it 'adds reallocation value to nonbasis start cell' do
      new_basis_plan[[0, 1]].should == 2
    end

    it 'doesnt touch basis cells that are not in cycle' do
      new_basis_plan[[0, 4]].should == 1
    end

    let(:sum_before) { plan.sum }
    let(:sum_after) { new_basis_plan.plan.sum }
    it 'doesnt change sum of transportations' do
      sum_after.should == sum_before
    end
  end
end