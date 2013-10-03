namespace :simplex do
  task :test => :environment do
    a = Matrix.new([1, 2, 0, -2, 4], [0, -1, 1, 4, -1])
    b = Matrix.new([2, 4]).transpose
    c = Matrix.new([2, 1, 3, 1, 6])
    task = LinearTask.new(:a => a, :b => b, :c => c)

    plan_vector = Matrix.new([2, 0, 4, 0, 0]).transpose
    basis = [2, 0]
    x = BasisPlan.new(plan_vector, basis)
    task_with_plan = LinearTaskWithBasis.new(task, x)

    solver = SimplexSolver.new(task_with_plan)
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
    task_with_plan = LinearTaskWithBasis.new(task, x)

    solver = SimplexSolver.new(task_with_plan)
    puts solver
    solver.logging = true
    solver.iterate
  end
end
