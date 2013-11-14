module NewTaskComposers
  class RestrictedDualSimplex < NewTaskComposers::DualSimplex

    def compose
      super.tap do |t|
        t.nonbasis_nonneg_est_idx = jn_plus
      end
    end

    # Given a task in initializer,
    # sets jn+ and jn- in t
    #
    def jn_plus
      if task.unfit_step_weight == 1
        jn_plus_for_positive_mu
      elsif task.unfit_step_weight == -1
        jn_plus_for_negative_mu
      else
        raise ArgumentError, "Unknown mu[jk]"
      end
    end

    # If mu[jk], or unfit step weight, was == 1
    #
    def jn_plus_for_positive_mu
      if task.nonbasis_nonneg_est_idx.include? task.step_index
        task.nonbasis_nonneg_est_idx - [task.step_index] + [task.unfit_kappa_basis_var]
      else
        task.nonbasis_nonneg_est_idx + [task.unfit_kappa_basis_var]
      end
    end

    def jn_plus_for_negative_mu
      if task.nonbasis_nonneg_est_idx.include? task.step_index
        task.nonbasis_nonneg_est_idx - [task.step_index]
      else
        task.nonbasis_nonneg_est_idx
      end
    end
  end
end
