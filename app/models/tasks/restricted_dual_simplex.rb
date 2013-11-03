module Tasks
  # Class for solving tasks with dual simplex method
  # where x (result) is restricted not like >= 0,
  # but c <= x <= d.
  #
  class RestrictedDualSimplex < Tasks::Base

    # + changes: in checking if is a plan
    # composing pseudoplan - needs separating restrictions
    # optimal criteria
    # kappa index
    # mu - needs separating restrictions
    # sigma
    # building new nonbasis upper and lower indices (not needed)
    #
    # @param x [Matrix] solution vector
    # @return [true, false] if x is task plan
    #
    def plan?
      sign_restrictions_apply?(coplan)
    end

    # number of basis indexes = equations number
    # non-basis components == 0,
    # basis matrix det != 0
    #
    def basis_plan?
      plan? &&
        plan.basis_indexes.length == task.m &&
        basis_det != 0 &&
        coplan_b.isnull?
    end

    def nonsingular_plan?
      basis_plan? &&
        coplan_n.ispos?
    end

    # Coplan, or delta, or estimates, is a vector that can be built by each plan.
    # delta = A' * y - c
    #
    # @return [Matrix] n-vector
    #
    def coplan
      @coplan ||= Matrix.from_gsl(coplan_gsl)
    end
    alias :delta :coplan

    # Nonbasis indices to which estimates are negative,
    # or Jn-
    #
    #
    def nonbasis_neg_est_idx
      @jn_minus ||= coplan.to_a.flatten.select.with_index do |d, idx|
        d < 0
      end.map(&:last)
    end

    # Nonbasis indices to which estimates are non negative
    # or Jn+
    #
    def nonbasis_nonneg_est_idx
      @jn_plus = nonbasis_indices - nonbasis_neg_est_idx
    end    

    # Pseudoplan, or kappa,
    # is built for each basis,
    # == inverted_basis_matrix * b
    # Nonbasis kappa == 0.
    #
    # @return [Array<Float>]
    #
    def pseudoplan
      @pseudoplan ||= compose_pseudoplan
    end
    alias :kappa :pseudoplan

    # @return [GSL::Matrix]
    #
    def pseudoplan_b
      @kappa_b ||= inverted_basis_matrix * (task.b - basis_pseudoplan_correction)
    end
    alias :kappa_b :pseudoplan_b

    def pseudoplan_b_ary
      pseudoplan_b.to_a.flatten
    end
    alias :kappa_b_ary :pseudoplan_b_ary

    # (kappa includes non-basis items also)
    # A position in basis of a variable
    # for which kappa that doesn't satisfy
    # sign restrictions stands, or nil
    #
    # E.g. if kappa[jk] < 0, returns k, if
    # j1, j2, ..., jk are basis variables.
    #
    def unfit_kappa_index
      @unfit_kappa_index ||= calculate_unfit_kappa_index
    end

    # @see #unfit_kappa_index
    # returns jk
    def unfit_kappa_basis_var
      plan.basis_indexes[unfit_kappa_index]
    end

    def sufficient_for_optimal?
      super && sign_restrictions_apply?(pseudoplan_b)
    end

    # TODO: always return?
    # If basis plan is optimal, returns optimal plan
    # for dual task (i.e. for usual)
    def result_plan
      @result_plan ||= BasisPlan.simple_init(pseudoplan, plan.basis_indexes)
    end

    # s, or dy. Vector
    #
    def step_multiplier
      @s ||= step_multiplier_string.transpose
    end

    # s', dy' = m0 * e'[k] * Ab^-1.
    #
    def step_multiplier_string
      @s_string ||= unfit_step_weight *
        Matrix.eye_row(:size => task.m, :index => unfit_kappa_index).to_matrix(1, task.m) *
        inverted_basis_matrix
    end

    # mu for kappa that didn't fit the 
    # sign restrictions
    #
    def unfit_step_weight
      @m0 ||= (pseudoplan[unfit_kappa_basis_var] < low_restr[unfit_kappa_basis_var] ? 1 : -1)
    end

    # sigma. N-vector
    #
    # @return [Array<Float>]
    #
    def steps
      @steps ||= steps_weight.map.with_index do |mu, j|
        compose_sigma(mu, j)
      end
    end

    # If there are less than infinity steps
    #
    def has_step?
      steps.any? { |s| s < Float::INFINITY }
    end

    # sigma0 - minimal of sigmas
    #
    def step
      step_with_index.first
    end

    # j0, sigma[j0] = sigma0 = step
    #
    def step_index
      step_with_index.last
    end

    def plan_delta
      step * step_multiplier
    end

    # mu. N-vector
    #
    # @return [Array<Float>]
    #
    def steps_weight
      @steps_weight ||= calculate_steps_weight
    end

    # Returns suitable first dual basis plan for given linear task
    #
    # @param linear_task [LinearTask] a, b, c
    # 
    # @return [GSL::Matrix] m-vector
    #
    def self.first_basis_plan_for(a, b, c, basis_indices)
      # potentials vector of the main task is a basis plan for dual
      linear_task = LinearTask.new(:a => a, :b => b, :c => c)
      plan = BasisPlan.new(nil, basis_indices)
      fake_task = Tasks::Simplex.new(linear_task, plan)
      BasisPlan.new(fake_task.potential_vector, basis_indices)
    end

    # not needed really, because by this
    # we can't tell about target function of the main task
    #
    def target_function
      (task.b.transpose * plan.x).get(0)
    end

    protected

    def calculate_unfit_kappa_index
      return unless unfit_kappas_with_indices
      indices = unfit_kappas_with_indices.map(&:last)
      basis_idx_for_unfit_kappas = basis_indexes.zip_indices.values_at(*indices)
      basis_idx_for_unfit_kappas.min_by(&:first).last
    end

    # kappas that don't fit sign restrictions
    # and their indices
    #
    def unfit_kappas_with_indices
      @unfit_kappas_with_indices ||= kappa_b_ary.each_with_index.find_all do |a, ind|
        !sign_restrictions_apply?(a, ind)
      end
    end

    # A' * y, vector
    #
    def a_y_prod
      @a_y_prod ||= task.a.transpose * plan.x
    end

    def coplan_gsl
      begin
        a_y_prod - task.c
      rescue TypeError
        a_y_prod - task.c.gsl_matrix
      end
    end

    def coplan_b
      coplan.cut_rows(plan.basis_indexes)
    end

    def coplan_n
      coplan.cut_rows(plan.nonbasis_indexes)
    end

    def compose_pseudoplan
      result = compose_nonbasis_pseudoplan

      # basis index and its position in basis
      plan.basis_indexes.each_with_index do |bas_ind, bas_pos|
        # kappa_b[pos] => see ind = basis_indices[pos] => x0[ind] = kappa_b[pos]
        result[bas_ind] = pseudoplan_b.get(bas_pos)
      end
      result
    end

    # To get basis pseudoplan, we need nonbasis pseudoplan
    # and to get whole pseudoplan we need basis one
    #
    # So this is n-vector with only nonbasis items set
    #
    def pseudoplan_with_nonbasis_items
      @pseudoplan_with_nonbasis_items ||= compose_nonbasis_pseudoplan
    end

    def compose_nonbasis_pseudoplan
      result = Array.new(task.n)
      nonbasis_neg_est_idx.each { |i| result[i] = up_restr[i] }
      nonbasis_nonneg_est_idx.each { |i| result[i] = low_restr[i] }
      result
    end

    # Will be subtracted from basis pseudoplan
    # to correct it according to nonbasis pseudoplan
    # values.
    #
    def basis_pseudoplan_correction
      nonbasis_indices.map do |i|
        task.a.cut([i]) * pseudoplan_with_nonbasis_items[i]
      end.sum
    end

    def calculate_steps_weight
      result = indices.map do |ind|
        (step_multiplier_string * task.a.cut([ind]).gsl_matrix).get(0)
      end
      # mu[jk] = 1 or -1, jk is variable num for unfit kappa
      result[unfit_kappa_basis_var] = unfit_step_weight
      result
    end



    def compose_sigma(mu, idx)
      if (mu < 0 && nonbasis_nonneg_est_idx.include?(idx) || 
          mu > 0 && nonbasis_neg_est_idx.include?(idx))
        -coplan.get(idx) / mu
      else
        Float::INFINITY
      end
    end

    # @return [Array] Maximal available step. Array format: [step, its index]
    #
    def step_with_index
      @step_with_index ||= steps.each_with_index.min_by(&:first)
    end
  end
end
