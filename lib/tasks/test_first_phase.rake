namespace :first_phase do
  task :test => :environment do
    a = Matrix.new([1, 2, 0, -2, 4], [1, 2, 0, -2, 4], [1, 1, 1, 1, 1])
    b = Matrix.new_vector([2, 2, 1]).gsl_matrix
    c = Matrix.new_vector([2, 1, 3, 1, 6])
    task = LinearTask.new(:a => a, :b => b, :c => c)
    analyzer = FirstPhaseSimplexAnalyzer.new(task)
    puts analyzer
    analyzer.logging = true

    analyzer.analyze
  end

  task :test_with_solver => :environment do
    # see test simplex
    a = Matrix.new([1, 2, 0, -2, 4], [1, 2, 0, -2, 4], [1, 1, 1, 1, 1])
    b = Matrix.new_vector([2, 2, 1]).gsl_matrix
    c = Matrix.new_vector([2, 1, 3, 1, 6])
    task = LinearTask.new(:a => a, :b => b, :c => c)
    analyzer = FirstPhaseSimplexAnalyzer.new(task)    
    puts analyzer
    analyzer.logging = true

    analyzer.analyze
    puts "\n-------------------------\npassing result to solver...\n-------------------------"
    solver = Solvers::Simplex.new(analyzer.result_task_with_basis)
    puts solver
    solver.logging = true
    solver.iterate
  end

  task :test_class => :environment do
    # a = Matrix.new( 
    #   [-1, -2, -1, -6, -1, 0],  
    #   [0, 3, 1, 0, 3, 1],
    #   [1, 1, 1, 2, 4, 0]
    # )
        a = Matrix.new( 
      [1, 2, -1, 6, -1, 0],  
      [0, -3, 1, 0, 3, 1],
      [1, 1, 1, -2, 4, 0]
    )
    b = Matrix.new([7, 2, 5]).transpose
    c = Matrix.new_vector([2, 1, 3, 1, 6, 1])

    task = LinearTask.new(:a => a, :b => b, :c => c)
    analyzer = FirstPhaseSimplexAnalyzer.new(task)    
    puts analyzer
    analyzer.logging = true

    analyzer.analyze    
  end
end
