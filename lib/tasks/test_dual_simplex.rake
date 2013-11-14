namespace :dual_simplex do
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
end
