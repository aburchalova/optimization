namespace :dual do
  task :test => :environment do
    a = Matrix.new([1, 0, 0, 1, -3, 4, 0, 1, 4], [2, 1, 2, 1, -5, 2, 0, -5, 2], [1, 1, 1, 1, 1, 1, 1, 1, 1])
    b = Matrix.new([1, 8, 6]).transpose
    c = Matrix.new_vector([-2, 2, 1, 3, 5, 10, 15, 4, 6])
    basis = [1, 2, 3]

    restr = { :lower => [-2, -2, -2, -2, 3, -2, -2, -2, -2], :upper => [2, 2, 2, 2, 3, 2, 2, 2, 2] }
    solver = Solvers::RestrictedDualSimplex.simple_init(a, b, c, basis, restr)
    puts solver
    solver.logging = true
    solver.iterate
  end

  task branch: :environment do
    a = Matrix.new(
      [5, 2, 1, 0],
      [2, 5, 0, 1]
    )
    b = Matrix.new([14, 16]).transpose
    c = Matrix.new_vector([3, 5, 0, 0])
    basis = [0, 1]

    restr = { :lower => [1, 1, 0, 0], :upper => [5, 5, 100000, 10000] }
    solver = Solvers::RestrictedDualSimplex.simple_init(a, b, c, basis, restr)
    puts solver
    solver.logging = true
    solver.iterate
  end

  task br1: :environment do
    a = Matrix.new(
      [1, 0, 0, 3, 1, -3, 4, -1],
      [0, 1, 0, 4, -3, 3, 5, 3],
      [0, 0, 1, 1, 0, 2, -2, 1]
    )
    b = Matrix.new([30, 78, 5]).transpose
    c = Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5])

    basis = [0, 1, 2]

    restr = { :lower => [0, 0, 0, 0, 0, 0, 0, 0], :upper => [5, 5, 3, 4, 5, 6, 6, 8] }
    solver = Solvers::RestrictedDualSimplex.simple_init(a, b, c, basis, restr)
    puts solver
    solver.logging = true
    solver.iterate
  end

    task br2: :environment do
    a = Matrix.new(
      [1, 0, 0, 3, 1, -3, 4, -1],
      [0, 1, 0, 4, -3, 3, 5, 3],
      [0, 0, 1, 1, 0, 2, -2, 1]
    )
    b = Matrix.new([3, 7, 5]).transpose
    c = Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5])

    basis = [6, 7, 0]

    restr = { :lower => [2, 0, 0, 0, 0, 0, 0, 0], :upper => [5, 5, 3, 4, 5, 6, 6, 8] }
    solver = Solvers::RestrictedDualSimplex.simple_init(a, b, c, basis, restr)
    puts solver
    solver.logging = true
    solver.iterate
  end

    task br3: :environment do
    a = Matrix.new(
      [1, 0, 0, 3, 1, -3, 4, -1],
      [0, 1, 0, 4, -3, 3, 5, 3],
      [0, 0, 1, 1, 0, 2, -2, 1]
    )
    b = Matrix.new([3, 7, 5]).transpose
    c = Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5])

    basis = [0, 1, 2]

    restr = { :lower => [0, 0, 0, 0, 0, 0, 0, 0], :upper => [1, 5, 3, 4, 5, 6, 6, 8] }
    solver = Solvers::RestrictedDualSimplex.simple_init(a, b, c, basis, restr)
    puts solver
    solver.logging = true
    solver.iterate
  end

    task br4: :environment do
    a = Matrix.new(
      [1, 0, 0, 3, 1, -3, 4, -1],
      [0, 1, 0, 4, -3, 3, 5, 3],
      [0, 0, 1, 1, 0, 2, -2, 1]
    )
    b = Matrix.new([3, 7, 5]).transpose
    c = Matrix.new_vector([2, 1, -2, -1, 4, -5, 5, 5])

    basis = [6, 7, 1]

    restr = { :lower => [2, 0, 0, 0, 0, 0, 0, 0], :upper => [5, 1, 3, 4, 5, 6, 6, 8] }
    solver = Solvers::RestrictedDualSimplex.simple_init(a, b, c, basis, restr)
    puts solver
    solver.logging = true
    solver.iterate
  end  

  # task br1: :environment do
  #   a = Matrix.new(
  #     [1, -5, 3, 1, 0, 0],
  #     [4, -1, 1, 0, 1, 0],
  #     [2, 4, 2, 0, 0, 1]
  #   )
  #   b = Matrix.new([-8, 22, 30]).transpose
  #   c = Matrix.new_vector([7, -2, 6, 0, 5, 2])

  #   # analyzer = FirstPhaseSimplexAnalyzer.new(LinearTask.new(a: a, b: b, c: c))
  #   # analyzer.analyze
  #   basis = [3, 4, 5] #analyzer.basis_plan.basis_indexes

  #   restr = { :lower => [2, 1, 0, 0, 1, 1], :upper => [6,6, 5, 2, 4, 6] }
  #   solver = Solvers::RestrictedDualSimplex.simple_init(a, b, c, basis, restr)
  #   puts solver
  #   solver.logging = true
  #   solver.iterate
  # end


end
