require 'spec_helper'

describe FirstPhaseSimplexAnalyzer do
  let(:a) { Matrix.new([1, 2, 0, -2, 4], [0, -1, 1, 4, -1]) }
  let(:b) { Matrix.new([2, 4]).transpose }
  let(:c) { Matrix.new([2, 1, 3, 1, 6]) }
  let(:task) { LinearTask.new(:a => a, :b => b, :c => c) }

  subject(:analyzer) { FirstPhaseSimplexAnalyzer.new(task) }
  it { analyzer.status.should be_initialized }

end