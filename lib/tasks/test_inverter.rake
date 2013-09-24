namespace :inverter do
  desc "Invert sample matrix"
  task :test => :environment do
    m = Matrix.new([0, 0, 5], [1, 2, 6], [3, 4, 7])
    puts "Matrix: \n#{m}\nInitializing matrix inverter........."
    mi = MatrixInverter.new(m)
    puts mi.to_s

    puts "\nStarting algorithm\nLogging enabled"
    mi.enable_log!

    mi.run

    puts "\nChecking result........."
    puts "Expected result: \n#{mi.expected}"
    puts "Actual result: \n#{mi.result}"
    puts "Check result: \n#{mi.check}"
  end

  task :bulk_test => :environment do
    size = (ENV['SIZE'] || 3).to_i
    test_count = (ENV['N'] || 10).to_i
    log = ENV['LOG'].to_s.downcase == "true" 
    puts "Testing with matrices of size #{size}"
    puts "#{test_count} test will be done. Dot for passed test, x for failed."
    puts "(You can set SIZE, N, LOG environment variables)"
    puts "Starting"
    test_count.times do
      m = Matrix.random(size)
      mi = MatrixInverter.new(m)
      mi.show_log = log
      mi.run
      print mi.check ? '.' : 'x'
    end
    puts
  end
end