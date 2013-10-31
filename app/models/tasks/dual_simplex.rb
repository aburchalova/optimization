# class for minimizing b'y, y is m-vector
# with A' * y >= c
module Tasks
  class DualSimplex < Tasks::Base
    #
    # @param x [Matrix] solution vector
    # @return [true, false] if x is task plan
    #
    def plan?
      sign_restrictions.call(coplan)
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

    # Coplan, or delta, is a vector that can be built by each plan.
    # delta = A' * y - c
    #
    # @return [Matrix]
    #
    def coplan
      @coplan ||= Matrix.from_gsl(coplan_gsl)
    end
    alias :delta :coplan

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
      @kappa_b ||= inverted_basis_matrix * task.b
    end
    alias :kappa_b :pseudoplan_b

    def pseudoplan_b_ary
      pseudoplan_b.to_a.flatten
    end
    alias :kappa_b_ary :pseudoplan_b_ary

    # (kappa includes non-basis items also)
    # A position in basis of a variable
    # for which negative kappa stands, or nil
    #
    # E.g. if kappa[jk] < 0, returns k, if
    # j1, j2, ..., jk are basis variables.
    #
    def neg_kappa_index
      @neg_kappa_index ||= calculate_neg_kappa_index
    end

    def sufficient_for_optimal?
      super && pseudoplan_b.isnonneg?
    end

    # TODO: always return?
    # If basis plan is optimal, returns optimal plan
    # for dual task (i.e. for usual)
    def result_plan
      @result_plan ||= BasisPlan.simple_init(pseudoplan, plan.basis_indexes)
    end

    # s = e'[k] * Ab^-1. Vector
    #
    def step_multiplier
      @s ||= step_multiplier_string.transpose
    end

    # s'
    #
    def step_multiplier_string
      @s_string ||= Matrix.eye_row(:size => task.m, :index => neg_kappa_index).to_matrix(1, task.m) *
        inverted_basis_matrix
    end

    # sigma. N-vector
    #
    # @return [Array<Float>]
    #
    def steps
      @steps ||= steps_weight.map.with_index do |mu, j|
        delta = coplan.get(j)
        compose_sigma(mu, delta)
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
      fake_task.potential_vector
    end

    def target_function
      (task.b.transpose * plan.x).get(0)
    end

    protected

    def calculate_neg_kappa_index
      return unless neg_kappas_with_indices
      min_kappas_indices = neg_kappas_with_indices.map(&:last)
      basis_idx_for_neg_kappas = basis_indexes.zip_indices.values_at(*min_kappas_indices)
      basis_idx_for_neg_kappas.min_by(&:first).last
    end

    def neg_kappas_with_indices
      @neg_kappas_with_indices ||= kappa_b_ary.find_all_with_indices(&:neg?)
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
      result = Array.new(task.n, 0)
      # basis index and its position in basis
      plan.basis_indexes.each_with_index do |bas_ind, bas_pos|
        # kappa_b[pos] => see ind = basis_indices[pos] => x0[ind] = kappa_b[pos]
        result[bas_ind] = pseudoplan_b.get(bas_pos)
      end
      result
    end

    def calculate_steps_weight
      (0...task.n).to_a.map do |ind|
        (step_multiplier_string * task.a.cut([ind]).gsl_matrix).get(0)
      end
    end

    def compose_sigma(mu, delta)
      mu.nonneg? ? Float::INFINITY : -delta / mu
    end

    # @return [Array] Maximal available step. Array format: [step, its index]
    #
    def step_with_index
      @step_with_index ||= steps.each_with_index.min_by(&:first)
    end
  end
end
