namespace :transport do
  task :test => :environment do
    a = [30, 40, 20]
    b = [20, 30, 30, 10]
    c = Matrix.new(
        [2, 3, 2, 4],
        [3, 2, 5, 1],
        [4, 3, 2, 6])
    data = TransportProblem::Data.new(a, b, c)
    task = Tasks::Transport.new(data)

    solver = Solvers::Transport.new(task)
    puts solver
    solver.logging = true
    solver.iterate
  end

  task :class => :environment do
    a = [20, 20, 30, 25]
    b = [15, 10, 5, 20, 30, 10, 5]
    c = Matrix.new(
        [5, 2, -3, 0, 7, 2, 5],
        [1, -4, 0, 5, 10, 2, 3],
        [3, 2, 5, 7, 10, 15, 1],
        [-5, 7, 5, 2, 8, 0, 7]
        )
    data = TransportProblem::Data.new(a, b, c)
    task = Tasks::Transport.new(data)

    solver = Solvers::Transport.new(task)
    puts solver
    solver.logging = true
    solver.iterate
  end

  task :appointment => :environment do
    a = [1, 1, 1, 1, 1, 1]
    b = [1, 1, 1, 1, 1, 1]
    c = Matrix.new(
        [5, 2, -3, 0, 7, 2],
        [5, 1, -4, 0, 5, 10],
        [2, 3, 3, 2, 5, 7],
        [10, 15, 1, -5, 7, 5],
        [2, 8, 0, 7, 1, 2],
        [10, -5, 0, 2, 3, 10]
        )
    data = TransportProblem::Data.new(a, b, c)
    task = Tasks::Transport.new(data)

    solver = Solvers::Transport.new(task)
    puts solver
    solver.logging = true
    solver.iterate
  end
end
