require 'spec_helper'

describe Solvers::Transport do

  context 'checking steps' do
    let(:a) { [30, 40, 20] }
    let(:b) { [20, 30, 30, 10] }
    let(:c) {
      Matrix.new(
        [2, 3, 2, 4],
        [3, 2, 5, 1],
        [4, 3, 2, 6])
    }
    let(:data) { TransportProblem::Data.new(a, b, c) }
    let(:task) { Tasks::Transport.new(data) }
    let(:solver) { solver = Solvers::Transport.new(task) }

    it 'calcs '
  end

  context 'appointment task' do

  end
end
