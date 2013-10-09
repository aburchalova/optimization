class Matrix
  attr_accessor :gsl_matrix
  include Comparable

  include Matrices::Optimization

  # args is array list
  def initialize(*args)
    @gsl_matrix = GSL::Matrix[*args]
    self
  end

  def self.from_gsl(gsl_matrix)
    self.new(*gsl_matrix.to_a)
  end

  # TODO: more effecient implementation
  def method_missing(method, *args)
    return @gsl_matrix.send(method, *args) if @gsl_matrix.respond_to?(method)
    super
  end

  def self.method_missing(method, *args)
    return GSL::Matrix.send(method, *args) if GSL::Matrix.respond_to?(method)
    super
  end

  def respond_to_missing?(method_name, include_private = false)
    @gsl_matrix.respond_to?(method_name) || super
  end

  def self.respond_to_missing?(method_name, include_private = false)
    GSL::Matrix.respond_to?(method_name) || super
  end

  # TODO: remove to_a because of precision
  def to_s
    gsl_matrix.to_s
  end

  def parsed
    to_a.to_s
  end

  def from_s(string)
    JSON.parse(string)
  end

  def <=>(other)
    return self.gsl_matrix <=> other.gsl_matrix if other.respond_to?(:gsl_matrix)
    return self.gsl_matrix <=> other
  end

  def ==(other)
    return false unless size1 == other.size1 && size2 == other.size2
    v2 = other.to_v.to_a
    to_v.to_a.each_with_index { |item, idx| return false if item != v2[idx] }
    true
  end


  # cuts columns +cols+ from matrix
  # as another matrix
  # 
  def cut(cols)
    # result = GSL::Matrix.alloc(size1, 1)
    # cols.each do |col| # problem: 1. matix view to matrix 2. initial result in horzcatting - cannot init a matrix with zero columns
    #   result = result.horzcat(self.column(col).to_m(size2, 1)) 
    # end
    # Matrix.from_gsl(result)
    cols = cols.dup
    first_col = cols.shift
    result = dup.submatrix(nil, first_col..first_col)
    cols.each do |col|
      result = result.horzcat submatrix(nil, col..col)
    end
    ::Matrix.from_gsl(result)
  end

  def self.random(n)
    items = (1..n).to_a
    rows = []
    n.times { rows << items.shuffle }
    Matrix.new(*rows)
  end
end
