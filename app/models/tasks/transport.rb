module Tasks
  class Transport
    attr_accessor :data, :plan

    # @param data [TransportProblem::Data]
    # @param plan [TransportProblem::BasisPlan]
    def initialize(data, plan)
      @data = data
      @plan = plan
    end

    def suppliers_potentials

    end
    alias :u :suppliers_potentials

    def consumers_potentials

    end
    alias :v :consumers_potentials
  end
end
