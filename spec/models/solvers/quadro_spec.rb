require 'spec_helper'

describe Solvers::Quadro do
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
    let(:task) { Tasks::Quadro.new(proper_data) }

    subject(:solver) { Solvers::Quadro.new(task) }

    context 'step1' do

      # it 'sets "optimal" status when all estimates positive' do
      #   solver.iterate
      #   solver.status.should be_optimal
      # end

    end

    context 'kostya test' do
      let(:a) { Matrix.new([1, 0, 0, 0, 1, 1, 4], [2, 1, 1, 0, -1, 0, 2], [1, -1, 0, 1, 1, 0, 1]) }
      let(:b) { Matrix.new([7, 5, 3]).transpose }
      let(:c) { Matrix.from_gsl(Matrix.ones(7, 1)) }
      let(:d) { Matrix.from_gsl(5 * Matrix.eye(7)) }
      let(:data) { Quadro::Data.new(:a => a, :b => b, :c => c, :d => d) }
      # let(:half_d) { Matrix.new([2, 3, 0, 0, 1, 1, -3], [4, -1, 1, 1, 0, 1, 0]) }
      let(:pillar) { [3, 4, 6] }
      let(:proper) { pillar }
      let(:plan_vector) { Matrix.new([0, 0, 5, 3, 0, 7, 0]).transpose }

      let(:x) { Quadro::PillarPlan.new(plan_vector, pillar) }
      let(:proper_data) { Quadro::ProperPillarData.new(data, x, proper) }
      let(:task) { Tasks::Quadro.new(proper_data) }

      subject(:solver) { Solvers::Quadro.new(task) }

      # it 'finds solution' do
      #   solver.iterate
      #   solver.result_ary.should == [1.0747, 0, 0.1091, 0.3333, 0.1475, 0, 1.4444]
      # end
    end

  end
end
