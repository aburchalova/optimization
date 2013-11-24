module NewTaskComposers
  class Transport
    attr_accessor :task

    def initialize(task)
      @task = task
    end

    def compose
      task.with(new_plan, new_basis)
    end

    def new_plan
      reallocator.reallocate.plan
    end

    def new_basis
      task.basis_plan.basis - [cell_to_remove] + [cell_to_add]
    end

    def reallocator
      @reallocator ||= TransportProblem::Reallocator.new(task.basis_plan, cell_to_add)
    end

    def cell_to_remove
      reallocator.reallocation_cell
    end

    def cell_to_add
      task.positive_estimate_cell
    end
  end
end
