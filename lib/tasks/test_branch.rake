namespace :int do

  task branch: :environment do
    a = Matrix.new(
      [5, 2, 1, 0],
      [2, 5, 0, 1]
    )
    b = Matrix.new([14, 16]).transpose
    c = Matrix.new_vector([3, 5, 0, 0])
    basis = [0, 1]

    restr = { :lower => [1, 1, 0, 0], :upper => [5, 5, 100000, 10000] }
    task = Integer::Task.new(
      LinearTask.new(a: a, b: b, c: c), 
      nil, 
      [0, 1], 
      restr)
    solver = Integer::BranchAndBoundMethod.new(task)
    puts solver
    solver.logging = true
    solver.iterate
  end

  task variant: :environment do
    a = Matrix.new(
      [1, 0, 0, 3, 1, -3, 4, -1],
      [0, 1, 0, 4, -3, 3, 5, 3],
      [0, 0, 1, 1, 0, 2, -2, 1]
    )
    b = Matrix.new([30, 78, 5]).transpose
    c = Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5])

    basis = [0, 1, 2]

    restr = { :lower => [0, 0, 0, 0, 0, 0, 0, 0], :upper => [5, 5, 3, 4, 5, 6, 6, 8] }

    task = Integer::Task.new(
      LinearTask.new(a: a, b: b, c: c), 
      nil, 
      (0..8).to_a, 
      restr)

    solver = Integer::BranchAndBoundMethod.new(task)
    puts solver
    solver.logging = true
    solver.iterate

  end

  task fuck: :environment do
    a = Matrix.new(
      [1, 0, 0, 3, 1, -3, 4, -1],
      [0, 1, 0, 4, -3, 3, 5, 3],
      [0, 0, 1, 1, 0, 2, -2, 1]
    )
    b = Matrix.new([3, 7, 5]).transpose
    c = Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5])

    basis = [0, 1, 2]

    restr = {:lower=>[4, 2, 0, 0, 0, 0, 0, 0], :upper=>[5, 5, 3, 4, 4, 6, 6, 8]}

    solver = Solvers::RestrictedDualSimplex.simple_init(a, b, c, basis, restr)
    puts solver
    solver.logging = true
    solver.iterate
  end
end
