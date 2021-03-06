namespace :simplex do
  task :simple_test => :environment do
    a = Matrix.new([1, 2, 0, -2, 4], [0, -1, 1, 4, -1])
    b = Matrix.new([2, 4]).transpose
    c = Matrix.new([2, 1, 3, 1, 6])
    task = LinearTask.new(:a => a, :b => b, :c => c)

    plan_vector = Matrix.new([2, 0, 4, 0, 0]).transpose
    basis = [2, 0]
    x = BasisPlan.new(plan_vector, basis)
    task_with_plan = Tasks::Simplex.new(task, x)

    solver = Solvers::Simplex.new(task_with_plan)
    puts solver
    solver.logging = true
    solver.iterate
  end

  task :test2 => :environment do
    a = Matrix.new([12, 3, 1, 0, 0], [4, 5, 0, 1, 0], [3, 14, 0, 0, 1])
    b = Matrix.new([264, 136, 266]).transpose
    c = Matrix.new([6, 4, 0, 0, 0])
    task = LinearTask.new(:a => a, :b => b, :c => c)

    plan_vector = Matrix.new([0, 0, 264, 136, 266]).transpose
    basis = [2, 3, 4]
    x = BasisPlan.new(plan_vector, basis)
    task_with_plan = Tasks::Simplex.new(task, x)

    solver = Solvers::Simplex.new(task_with_plan)
    puts solver
    solver.logging = true
    solver.iterate
  end

  task :test => :environment do
    a = Matrix.new([1, 0, 0, 1, -3, 4, 0, 1, 4], [2, 1, 2, 1, -5, 2, 0, -5, 2], [1, 1, 1, 1, 1, 1, 1, 1, 1])
    b = Matrix.new([1, 8, 6]).transpose
    c = Matrix.new([-2, 2, 1, 3, 5, 10, 15, 4, 6])
    task = LinearTask.new(:a => a, :b => b, :c => c)

    plan_vector = Matrix.new([0, 3, 2, 1, 0, 0, 0, 0, 0]).transpose
    basis = [2, 1, 3]

    # a = Matrix.new([2, 0, 1, -1, 0, 1, 1, -2, 0], [-1, 3, 1, -1, 1, 2, 0, 4, 0], [0, 4, 2, 0, 0, 1, 0, 5, 1])
    # b = Matrix.new([4, 3, 5]).transpose
    # c = Matrix.new([4, 2, 1, -2, 0, 3, 2, -1, 0])
    # task = LinearTask.new(:a => a, :b => b, :c => c)

    # plan_vector = Matrix.new([0, 0, 0, 0, 3, 0, 4, 0, 5]).transpose
    # basis = [4, 6, 8]

    x = BasisPlan.new(plan_vector, basis)
    task_with_plan = Tasks::Simplex.new(task, x)

    solver = Solvers::Simplex.new(task_with_plan)
    puts solver
    solver.logging = true
    solver.iterate
  end
end
