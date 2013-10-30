module NewTaskComposers
  class Simplex < NewTaskComposers::Base

    def new_plan
      result = Array.new(task.n, 0)
      fill_basis_components(result)
      fill_non_basis_components(result)
      Matrix.new(result).transpose
    end

    # Index of minimal theta. New basis matrix will be different by this column
    def var_to_remove_index
      task.min_theta_index
    end

    def var_to_add
      task.j0
    end

    protected

    def fill_basis_components(result)
      # for each i in basis indexes newx[j_i] = x[j_i] - min_theta * z[i]
      task.z_ary.each_with_index do |zi, i|
        x_idx = task.basis_indexes[i]
        result[x_idx] = task.x_ary[x_idx] - task.min_theta * zi
      end
      result
    end

    def fill_non_basis_components(result)
      result[task.j0] = task.min_theta
      result
    end

  end
end
