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

end
