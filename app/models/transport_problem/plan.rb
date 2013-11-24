module TransportProblem
  class Plan < DelegateClass(Matrix)

    def self.blank(rowcount, colcount)
      matr = Matrix.from_gsl(Matrix.zeros(rowcount, colcount))
      TransportProblem::Plan.new(matr)
    end

    def []=(cell, value)
      set(cell[0], cell[1], value)
    end

    def clone
      self.class.new(__getobj__.clone)
    end

  end
end
