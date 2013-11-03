module NewTaskComposers
  class DualSimplex < NewTaskComposers::Base
    def new_plan
      task.plan + task.plan_delta
    end

    # Index of minimal theta. New basis matrix will be different by this column
    def var_to_remove_index
      task.unfit_kappa_index
    end

    def var_to_add
      task.step_index
    end
  end

end
