require 'spec_helper'

describe Quadro::Steps do
  let(:data) { double(:ProperData,
    :plan => Matrix.new([2, 0, 1]).transpose,
    :d => Matrix.eye(3)
    ) }
  let(:estimate) { -4 }
  let(:estimate_idx) { 1 }

  before do
    Quadro::Direction.any_instance.stub(:get => Matrix.new([-1, 1, -1]).transpose)
  end

  subject(:steps) { Quadro::Steps.new(data, estimate, estimate_idx) }

  describe '#for_direct_constraints' do
    it { steps.for_direct_constraints.should == [2, Float::INFINITY, 1] }
  end

  describe '#for_target_function' do
    it { steps.for_target_function.should == 4.0/3 }
  end

  describe '#all_steps' do
    it { steps.all_steps.should == [2, 4.0/3, 1] }
  end

  describe '#find_index' do
    it { steps.find_index.should == 2 }
  end

  describe '#step' do
    it { steps.step.should == 1 }
  end
end
