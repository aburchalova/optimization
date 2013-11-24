module Tasks
  class Transport
    attr_accessor :data, :basis_plan

    # @param data [TransportProblem::Data]
    # @param options [Hash] :method => :min | :corner
    #
    def initialize(data, options = {})
      # raise ArgumentError, 'Incompatible constraints!' unless 
      @data = data.chomp      
    end

    def basis_plan
      @basis_plan ||= TransportProblem::FirstPlan.for(data)
    end

    def compatible?
      data.valid_constraints?
    end

    def u_and_v
      @u_and_v ||= TransportProblem::Potentials.for(data, basis_plan.basis)
    end

    def suppliers_potentials
      @u ||= u_and_v.first
    end
    alias :u :suppliers_potentials

    def consumers_potentials
      @v ||= u_and_v.last
    end
    alias :v :consumers_potentials

    def sufficient_for_optimal?
      positive_estimate_cell == nil
    end

    def estimates
      optimality.estimates
    end

    def positive_estimate_cell
      @cell0 ||= optimality.positive_estimate_cell
    end

    def cycle
      reallocator.cycle
    end

    def reallocation_cell
      reallocator.reallocation_cell
    end



    def with(new_plan, new_basis)
      t = self.class.new(data)
      t.basis_plan = TransportProblem::BasisPlan.new(new_plan, new_basis)
      t
    end

    def optimality
      @opt ||= TransportProblem::Optimality.new(data, basis_plan.basis, u_and_v)
    end

    def reallocator
      @realloc ||= TransportProblem::Reallocator.new(basis_plan, positive_estimate_cell)
    end

    def description
      %Q(Basis plan: #{basis_plan.to_s}
        Potentials: u = #{u}, v = #{v}
        Estimates: \n#{estimates}
        Target function: #{target_function}
    )
    end

    def target_function
      data.flat_all_cells.inject(0) { |sum, cell| sum += basis_plan[cell] * data.c[*cell] }
    end

    def to_s
      res = description
      res += description_for_non_optimal unless sufficient_for_optimal?
      res
    end

    def description_for_non_optimal
      %Q(Positive estimate cell #{positive_estimate_cell}
        Cycle: #{cycle}
        Reallocation value cell: #{reallocation_cell}
      )
    end
  end
end
