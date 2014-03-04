# A class for solving
# c'x -> max
# Ax = b
# c <= x <= d
# xj - integer, for j in J* 

class Integer::Task < Tasks::Base
  attr_accessor :integer_restrictions

  # @param integer_restrictions [Array]
  #
  def initialize(task, plan, integer_restrictions, sign_restrictions = {})
    @integer_restrictions = integer_restrictions
    super(task, plan, sign_restrictions)
  end

  def target_function
    (task.c_string * plan.x).get(0)
  end

  # If all indexes in integer_restrictions correspond to and integer variable
  #
  def satisfies_integer?(current_plan)
    integer_restrictions.all? { |i| current_plan.x_ary[i].to_f.int? }
  end

  # All indices of variables that need to be integer but are not
  # 
  # @return [Array] empty array if everything corresponds
  def noninteger_vars_with_indices(current_plan)
    current_plan.x_ary.each_with_index.find_all do |value, idx| 
      integer_restrictions.include?(idx) && !value.int?
    end
  end

  def first_noninteger_var_with_index(current_plan)
    noninteger_vars_with_indices(current_plan).first
  end

  # fixnum index if there is a variable that doesn't satisfy restrictions, nil otherwise
  def first_noninteger_index(current_plan)
    first_noninteger_var_with_index(current_plan).last
  end

  # float if there is a variable that doesn't satisfy restrictions, nil otherwise
  def first_noninteger_var(current_plan)
    first_noninteger_var_with_index(current_plan).first
  end

end
