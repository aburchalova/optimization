module NewTaskComposers
  class Base
    attr_accessor :task

    def initialize(task)
      @task = task
    end

    def compose
      inverted_new_matrix = new_a_b_inv
      task.with(new_plan, new_basis).tap do |t|
        t.inverted_basis_matrix = inverted_new_matrix
      end
    end

    def new_basis
      task.basis_indexes.dup.tap { |indices| indices[var_to_remove_index] = var_to_add }
    end

    def new_plan
      raise NotImplementedError
    end

    # Index of a variable in current basis that can be removed
    #
    def var_to_remove_index
      raise NotImplementedError
    end

    # Variable number that can be added to basis
    #
    def var_to_add
      raise NotImplementedError
    end

    def var_to_remove
      task.basis_indexes[var_to_remove_index]
    end

    def new_a_b
      task.a.cut(new_basis)
    end

    def new_a_b_inv
      new_a_b.inverse(task.a_b_inv, var_to_remove_index)
    end

  end
end
