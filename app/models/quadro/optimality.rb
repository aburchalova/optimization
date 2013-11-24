module Quadro
  class Optimality

    def optimal?
      negative_estimate_idx == nil
    end

    def negative_estimate_idx
      @negative_estimate_idx ||= estimates.index(:neg?)
    end

    def estimates

    end

    def potentials

    end

    # c_with_line(x) = c + Dx
    #
    def dependent_target
      @c_line ||= 
    end
    alias :c_line :dependent_target

  end
end
