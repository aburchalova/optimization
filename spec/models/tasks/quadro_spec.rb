require 'spec_helper'

describe Tasks::Quadro do
  context 'when D is zero' do

    let(:a) { Matrix.new([1, 2, 0, -2, 4], [0, -1, 1, 4, -1]) }
    let(:b) { Matrix.new([2, 4]).transpose }
    let(:c) { Matrix.new_vector([2, 1, 3, 1, 6]) }
    let(:d) { Matrix.from_gsl(Matrix.zeros(5, 5)) }
    let(:data) { Quadro::Data.new(:a => a, :b => b, :c => c, :d => d) }

    let(:plan_vector) { Matrix.new([2, 0, 4, 0, 0]).transpose }
    let(:pillar) { [2, 0] }
    let(:x) { Quadro::PillarPlan.new(plan_vector, pillar) }
    let(:proper_data) { Quadro::ProperPillarData.new(data, x, pillar) }
    subject(:task) { Tasks::Quadro.new(proper_data) }

    it 'calculates estimates' do
      task.estimates.should == [0, 0, 0, -7, 1]
    end


  end
end
