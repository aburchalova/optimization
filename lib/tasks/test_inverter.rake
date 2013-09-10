namespace :inverter do
  desc "Invert sample matrix"
  task :test => :environment do
    m = Matrix.new([0, 0, 5], [1, 2, 6], [3, 4, 7])
    puts "Matrix: \n#{m}\nInitializing matrix inverter........."
    mi = MatrixInverter.new(m)
    puts mi.to_s
    sleep(2)

    puts "\nStarting algorithm\nLogging enabled"
    mi.enable_log!

    mi.run

    puts "\nChecking result........."
    puts "Expected result: \n#{mi.expected}"
    puts "Actual result: \n#{mi.result}"
    puts "Check result: \n#{mi.check}"
  end

  task :bulk_test => :environment do
    size = ENV['SIZE'] || 3
    test_count = ENV['N'] || 10
    log = ENV['LOG'] || false
    puts "Testing with matrices of size #{size}"
    puts "#{test_count} test will be done. Dot for passed test, x for failed."
    puts "Starting"
    test_count.times do
      m = Matrix.random(size)
      mi = MatrixInverter.new(m)
      # mi.enable_log!
      mi.run
      puts mi.check ? '.' : 'x'
    end
  end
end