# Metaclass for LinearTask for simplex method and
# LinearTask for double simplex method
#
module Tasks
  class Base
    attr_accessor :task, :plan, :sign_restrictions
    attr_writer :inverted_basis_matrix
    delegate :m, :n, :a, :b, :c, :to => :task
    delegate :basis_indexes, :x_ary, :to => :plan

    # @param sign_restrictions [Hash]
    # @option sign_restrictions :lower [Array<Float>] n-array
    # @option sign_restrictions :upper [Array<Float>] n-array
    #
    def initialize(task, plan, sign_restrictions = {})
      @task, @plan = task, plan
      sign_restrictions[:lower] ||= Array.new(task.n, 0)
      sign_restrictions[:upper] ||= Array.new(task.n, Float::INFINITY)
      @sign_restrictions = sign_restrictions
    end

    def low_restr
      sign_restrictions[:lower]
    end

    def up_restr
      sign_restrictions[:upper]
    end

    def lower_sign_restriction_apply?(x = plan.x)
      x.to_a.flatten.zip(low_restr).all? do |x_item, restr_item|
        x_item >= restr_item
      end
    end

    def upper_sign_restriction_apply?(x = plan.x)
      x.to_a.flatten.zip(up_restr).all? do |x_item, restr_item|
        x_item <= restr_item
      end
    end   

    def sign_restrictions_apply?(x = plan.x)
      lower_sign_restriction_apply?(x) && upper_sign_restriction_apply?(x)
    end

    # plan_vect is array, makes matrix
    #
    def with(plan_vect, basis_indices)
      self.class.new(task, BasisPlan.new(plan_vect, basis_indices), sign_restrictions)
    end

    def with_restrictions(restr)
      restr[:lower] ||= low_restr
      restr[:upper] ||= up_restr
      self.class.new(task, plan, restr)
    end

    def basis_matrix
      @a_b ||= task.a.cut(plan.basis_indexes)
    end
    alias :a_b :basis_matrix

    def singular_basis_matrix?
      a_b.det.zero?
    end

    def inverted_basis_matrix
      @inverted_basis_matrix ||= a_b.invert
    end

    # Ability to pass already calculated matrix for optimization
    #
    def inverted_basis_matrix=(matrix)
      @inverted_basis_matrix ||= matrix
    end
    alias :a_b_inv :inverted_basis_matrix
    alias :a_b_inv= :inverted_basis_matrix=

    def nonbasis_matrix
      @a_n ||= task.a.cut(plan.nonbasis_indexes)
    end
    alias :a_n :nonbasis_matrix

    def basis_det
      @basis_det ||= basis_matrix.det
    end
    alias :a_b_det :basis_det

    def sufficient_for_optimal?
      !singular_basis_matrix?
    end

    def result_plan
      raise NotImplementedError
    end
  end
end
