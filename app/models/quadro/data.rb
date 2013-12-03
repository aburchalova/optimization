module Quadro
  class Data
    attr_accessor :a, :b, :c, :d

    def initialize(hash)
      self.a = hash[:a]
      self.b = hash[:b]
      self.c = hash[:c]
      self.d = hash[:d]
    end

    # c_with_line(x) = c + Dx
    #
    # @param x [Matrix] vector
    #
    def dependent_c(x)
      x = x.gsl_matrix if x.respond_to?(:gsl_matrix)
      Matrix.from_gsl(c + d * x)
    end
    alias :c_line :dependent_c

    def indices
      @j ||= (0...a.size2).to_a
    end

    def rowcount
      a.size1
    end

    def colcount
      a.size2
    end

  end
end
