module Quadro
  class Steps
    attr_accessor :proper_data, :estimate, :estimate_index

    # Estimate is a negative (that didn't fit optimality restrictions) estimate
    # and estimate_index is its index (from 0 to variables number)
    #
    def initialize(proper_data, estimate, estimate_index) #estimates - not needed, only theta j0 needed
      @proper_data = proper_data
      @estimate = estimate
      @estimate_index = estimate_index
    end

    # Steps that are allowed by direct constraints
    #
    def for_direct_constraints
      #direction is zero or 1 for non-proper indices
      @theta ||= direction.to_a.flatten.map.with_index do |l, j|
        l.nonneg? ? Float::INFINITY : -proper_data.plan.get(j) / l.to_f
      end
    end

    # Step that's allowed by target function
    #
    def for_target_function
      # - as taking abs and that estimate is negative
      @theta_j0 = direction_value.zero? ? Float::INFINITY : -estimate.to_f / direction_value
    end

    def all_steps
      @thetas = for_direct_constraints.dup.tap do |steps|
        steps[estimate_index] = for_target_function
      end
    end

    def find
      @theta0 ||= all_steps.min
    end
    alias :step :find

    def find_index
      all_steps.index(step)
    end

    # l' * D * l
    #
    def direction_value
      @ldl ||= (direction.transpose * proper_data.d * direction).get(0)
    end

    def direction
      @direction ||= Direction.new(proper_data, estimate_index).get
    end
  end
end
