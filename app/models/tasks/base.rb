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
      @sign_restrictions = compose_restrictions(sign_restrictions)
    end

    def low_restr
      sign_restrictions[:lower]
    end

    def up_restr
      sign_restrictions[:upper]
    end

    # Checks lower sign restrictions for all x items (if index not supplied)
    # or just #ind restriction for given item
    #
    def lower_sign_restriction_apply?(x = plan.x, ind = nil)
      return x >= low_restr[ind] if ind
      x.to_a.flatten.zip(low_restr).all? do |x_item, restr_item|
        x_item >= restr_item
      end
    end

    # Checks upper sign restrictions for all x items (if index not supplied)
    # or just #ind restriction for given item
    #
    def upper_sign_restriction_apply?(x = plan.x, ind = nil)
      return x <= up_restr[ind] if ind
      x.to_a.flatten.zip(up_restr).all? do |x_item, restr_item|
        x_item <= restr_item
      end
    end   

    # Checks sign restrictions for all x items (if index not supplied)
    # or just #ind restriction for given item
    #
    def sign_restrictions_apply?(x = plan.x, ind = nil)
      lower_sign_restriction_apply?(x, ind) && upper_sign_restriction_apply?(x, ind)
    end

    # plan_vect is array, makes matrix
    #
    def with(plan_vect, basis_indices)
      self.class.new(task, BasisPlan.new(plan_vect, basis_indices), sign_restrictions)
    end

    def with_restrictions(restr)
      restr[:lower] ||= low_restr #TODO: change
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

    def indices
      @j ||= (0...task.n).to_a
    end

    def nonbasis_indices
      @jn ||= indices - plan.basis_indexes
    end

    protected

    def compose_restrictions(sign_restrictions)
      sign_restrictions[:lower] = compose_restriction(sign_restrictions[:lower])
      sign_restrictions[:upper] = compose_restriction(sign_restrictions[:upper], Float::INFINITY)
      sign_restrictions
    end

    # If data is float, composes array with such item
    #
    # @param data [Array, Float]
    #
    def compose_restriction(data, default_value = 0)
      data = Array.new(task.n, data || default_value) unless data.is_a?(Enumerable)
      data
    end
  end
end
