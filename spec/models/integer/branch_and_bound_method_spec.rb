require 'spec_helper'

describe Integer::BranchAndBoundMethod do

  describe '#step' do
    it 'removes one task from the list'
    context 'when task has no plan' do
      it 'sets status to incompatible'
    end

    context 'when tasks optimal plan corresponds to integer conditions' do

    end

    context 'when tasks optimal plan doesnt correspond to integer conditions' do

    end


    it ''
  end

  context 'checking steps' do
    let(:a) { Matrix.new(
      [5, 2, 1, 0],
      [2, 5, 0, 1]
    ) }
    let(:b) { Matrix.new([14, 16]).transpose }
    let(:c) { Matrix.new_vector([3, 5, 0, 0]) }
    let(:restr) { { :lower => [1, 1, 0, 0], :upper => [5, 5, 100000, 10000] } }
    let(:task) { Integer::Task.new(
      LinearTask.new(a: a, b: b, c: c),
      nil,
      [0, 1],
    restr) }
    let(:solver) { Integer::BranchAndBoundMethod.new(task) }

    it 'first basis' do
      solver.fill_first_task
      solver.tasks_list.length.should == 1
      task = solver.tasks_list.first
      task.is_a?(Tasks::RestrictedDualSimplex).should be_true
      task.plan.basis_indexes.should == [0, 1]
    end

    it 'first step' do

    end
  end

  context 'variant task' do

    let(:a) { Matrix.new(
      [1, 0, 0, 3, 1, -3, 4, -1],
      [0, 1, 0, 4, -3, 3, 5, 3],
      [0, 0, 1, 1, 0, 2, -2, 1]
    ) }
    let(:b) { Matrix.new([30, 78, 5]).transpose }
    let(:c) { Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5]) }
    let(:restr) { { :lower => [0] * 8, :upper => [5, 5, 3, 4, 5, 6, 6, 8] } }
    let(:task) { Integer::Task.new(
      LinearTask.new(a: a, b: b, c: c),
      nil,
      (0..8).to_a,
    restr) }
    let(:solver) { Integer::BranchAndBoundMethod.new(task) }

    

    context 'before first step' do
      before { solver.fill_first_task }
      it 'fills first task' do
        solver.tasks_list.length.should == 1
        task = solver.tasks_list.first
        task.is_a?(Tasks::RestrictedDualSimplex).should be_true
        task.plan.basis_indexes.should == [0, 1, 2]
        task.low_restr.should == [0] * 8
        task.up_restr.should == [5, 5, 3, 4, 5, 6, 6, 8]
      end

      it 'initializes record' do
        solver.record.should == -Float::INFINITY
        solver.has_record.should == false
        solver.record_plan.should == nil
      end
    end


    context 'step 1' do
      before { solver.fill_first_task }
      before { solver.step }
      before { stub_const('Float::COMPARISON_PRECISION', 0.01) }

      it 'finds result basis' do
        solver.current_basis_plan.basis_indexes.should == [5, 2, 4]
        solver.current_basis_plan.x_ary.should == [5.0, 5.0, 3.0, 4.0, 0.0, 1, 6.0, 8.0]
      end
      it 'removes first task from list' do
        solver.tasks_list.should_not include(solver.current_task)
      end
      # it 'splits task into two' do
      #   solver.tasks_list.length.should == 2
      # end

      # let(:restr_lower_modified) { {:lower=>[0, 0, 0, 0, 0, 0, 0, 0], :upper=>[5, 5, 3, 4, 5, 0, 6, 8]} }
      # let(:restr_upper_modified) { {:lower=>[0, 0, 0, 0, 0, 1, 0, 0], :upper=>[5, 5, 3, 4, 5, 6, 6, 8]} }

      # it 'splits restrictions' do
      #   new_restrictions = solver.tasks_list.map &:sign_restrictions
      #   new_restrictions.should include(restr_lower_modified)
      #   new_restrictions.should include(restr_upper_modified)
      # end

      # it 'doesnt change record' do
      #   solver.record.should == -Float::INFINITY
      #   solver.has_record.should == false
      #   solver.record_plan.should == nil
      # end

    end

    context 'solution' do
      it 'finds record and record plan' do
        solver.logging = true
        solver.iterate
        solver.record.should == 70
        solver.record_ary.should == [5, 5, 3, 4, 0, 1, 6, 8]
      end

    end
  end

  it 'task 1' do
    a = Matrix.new(
    [1, 0, 0, 12, 1, -3, 4, -1],
    [0, 1, 0, 11, 12, 3, 5, 3],
    [0, 0, 1, 1, 0, 22, -2, 1]
    )
    b = Matrix.new([40, 107, 61]).transpose
    c = Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5])
    sign_restr = { lower: [0] * 8, upper: [3, 5, 5, 3, 4, 5, 6, 3] }

    solver = Integer::BranchAndBoundMethod.simple_init(a, b, c, (0..7).to_a, sign_restr)
    solver.iterate
    solver.record.should == 39
    solver.record_ary.should == [1, 1, 2, 2, 3, 3, 6, 3]
  end

  it 'task 2' do
    a = Matrix.new(
    [1, -3, 2, 0, 1, -1, 4, -1, 0],
    [1, -1, 6, 1,0, -2, 2, 2, 0],
    [2, 2, -1, 1, 0, -3, 8, -1, 1],
    [4, 1, 0, 0, 1, -1, 0, -1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1]
    )
    b = Matrix.new([3, 9, 9, 5, 9]).transpose
    c = Matrix.new_vector([-1, 5, -2, 4, 3, 1, 2,8, 3])
    sign_restr = { lower: [0] * 9, upper: [5] * 9 }

    solver = Integer::BranchAndBoundMethod.simple_init(a, b, c, (0..8).to_a, sign_restr)
    solver.iterate
    solver.record.should == 23
    solver.record_ary.should == [1] * 9
  end

  it 'task 3' do
    a = Matrix.new(
    [1, 0, 0, 12, 1, -3, 4, -1, 2.5, 3],
    [0, 1, 0, 11, 12, 3, 5, 3, 4, 5.1],
    [0, 0, 1, 1, 0, 22, -2, 1, 6.1, 7]
    )
    b = Matrix.new([43.5, 107.3, 106.3]).transpose
    c = Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5, 1, 2])
    sign_restr = { lower: [0] * 10, upper: [2, 4, 5, 3, 4, 5, 4, 4, 5, 6] }

    solver = Integer::BranchAndBoundMethod.simple_init(a, b, c, (0..9).to_a, sign_restr)
    solver.iterate
    solver.record.should == 29
    solver.record_ary.should == [1, 1, 2, 2, 2, 3, 3, 3, 3, 3]
  end

  it 'task 4' do
    a = Matrix.new(
    [4, 0, 0, 0, 0, -3, 4, -1, 2, 3],
    [0, 1, 0, 0, 0, 3, 5, 3, 4, 5],
    [0, 0, 1, 0, 0, 22, -2, 1, 6, 7],
    [0, 0, 0, 1, 0, 6, -2, 7, 5, 6],
    [0, 0, 0, 0, 1, 5, 5, 1, 6, 7]
    )
    b = Matrix.new([8, 5, 4, 7, 8]).transpose
    c = Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5, 1, 2])
    sign_restr = { lower: [0] * 10, upper: [10] * 10 }

    solver = Integer::BranchAndBoundMethod.simple_init(a, b, c, (0..9).to_a, sign_restr)
    solver.iterate
    solver.record.should == 26
    solver.record_ary.should == [2, 5, 4, 7, 8, 0, 0, 0, 0, 0]
  end


  # it 'task 5', :focus do
  #   a = Matrix.new(
  #   [1, -5, 3, 1, 0, 0],
  #   [4, -1, 1, 0, 1, 0],
  #   [2, 4, 2, 0, 0, 1]
  #   )
  #   b = Matrix.new([-8, 22, 30]).transpose
  #   c = Matrix.new_vector([7, -2, 6, 0, 5, 2])
  #   sign_restr = { :lower => [2, 1, 0, 0, 1, 1], :upper => [6,6, 5, 2, 4, 6] }
  #   solver = Integer::BranchAndBoundMethod.simple_init(a, b, c, (0..5).to_a, sign_restr, printing: true, logging: true)
  #   solver.iterate
  #   solver.record.should == 53
  #   solver.record_ary.should == [6, 3, 0, 1, 1, 6]
  # end

  it 'task 7' do
    a = Matrix.new(
    [1, -3, 2, 0, 1, -1, 4, -1, 0],
    [1, -1, 6, 1, 0, -2, 2, 2, 0],
    [2, 2, -1, 1, 0, -3, 2, -1, 1],
    [4, 1, 0, 0, 1, -1, 0, -1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1]
    )
    b = Matrix.new([18, 18, 30, 15, 18]).transpose
    c = Matrix.new_vector([7, 5, -2, 4, 3, 1, 2, 8, 3])
    sign_restr = { lower: [0] * 9, upper: [8] * 9 }

    solver = Integer::BranchAndBoundMethod.simple_init(a, b, c, (0..8).to_a, sign_restr, basis: [0,1, 2, 3, 4])
    solver.iterate
    solver.record.should == 78
    solver.record_ary.should == [3, 5, 0, 0, 0, 0, 8, 2, 0]
  end

  it 'task 8' do
    a = Matrix.new(
    [1, 0, 1, 0, 4, 3, 4],
    [0, 1, 2, 0, 55, 3.5, 5],
    [0, 0, 3, 1, 6, 2, -2.5]
    )
    b = Matrix.new([26, 185, 32.5]).transpose
    c = Matrix.new_vector([1, 2, 3, -1, 4, -5, 6])
    sign_restr = { lower: [0, 1, 0, 0, 0, 0, 0], upper: [1, 2, 5, 7, 8, 4, 2] }

    solver = Integer::BranchAndBoundMethod.simple_init(a, b, c, (0..9).to_a, sign_restr)
    solver.iterate
    solver.record.should == 18
    solver.record_ary.should == [1, 2, 3, 4, 3, 2, 1]
  end

  it 'task 9' do
    a = Matrix.new(
    [2, 0, 1, 0, 0, 3, 5],
    [0, 2, 2.1, 0, 0, 3.5, 5],
    [0, 0, 3, 2, 0, 2, 1.1],
    [0, 0, 3, 0, 2, 2, -2.5]
    )
    b = Matrix.new([58, 66.3, 36.7, 13.5]).transpose
    c = Matrix.new_vector([1, 2, 3, 1, 2, 3, 4])
    sign_restr = { lower: [1] * 7, upper: [2, 3, 4, 5, 8, 7, 7] }

    solver = Integer::BranchAndBoundMethod.simple_init(a, b, c, (0..6).to_a, sign_restr)
    solver.iterate
    solver.record.should == 74
    solver.record_ary.should == [1, 2, 3, 4, 5, 6, 7]
  end

  it 'task 10' do
    a = Matrix.new(
    [1, 0, 0, 1, 1, -3, 4, -1, 3, 3],
    [0, 1, 0, -2, 1, 1, 7, 3, 4, 5],
    [0, 0, 1, 1, 0, 2, -2, 1, -4, 7]
    )
    b = Matrix.new([27, 6, 18]).transpose
    c = Matrix.new_vector([-2, 1, -2, -1, 8, -5, 3, 5, 1, 2])
    sign_restr = { lower: [0] * 10, upper: [8, 7, 6, 7, 8, 5, 6, 7, 8, 5] }

    solver = Integer::BranchAndBoundMethod.simple_init(a, b, c, (0..9).to_a, sign_restr)
    solver.iterate
    solver.record_ary.should == [5, 0, 6, 7, 8, 0, 1, 0, 0, 1]
    solver.record.should == 40
    
  end
end
