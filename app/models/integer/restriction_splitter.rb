class Integer::RestrictionSplitter
  attr_accessor :plan, :integer_restrictions, :sign_restrictions

  # plan BasisPlan
  # integer_restrictions Array<Fixnum>
  # sign_restrictions Hash { lower: [...], upper: [...] }
  def initialize(plan, integer_restrictions, sign_restrictions)
    @plan = plan
    @integer_restrictions = integer_restrictions
    @sign_restrictions = sign_restrictions
  end

  # All indices of variables that need to be integer but are not
  # 
  # @return [Array] empty array if everything corresponds
  def noninteger_vars_with_indices
    @nonint_with_indices ||= plan.x_ary.each_with_index.find_all do |value, idx| 
      integer_restrictions.include?(idx) && !value.int?
    end
  end

  def first_noninteger_var_with_index
    noninteger_vars_with_indices.first
  end

  # fixnum index if there is a variable that doesn't satisfy restrictions, nil otherwise
  def first_noninteger_index
    first_noninteger_var_with_index.last
  end

  # float if there is a variable that doesn't satisfy restrictions, nil otherwise
  def first_noninteger_var
    first_noninteger_var_with_index.first
  end

  # From sign restrictions of this task compose two restrictions that are
  # the same as current except the restrictions for item on position j0
  # where j0 is the position of item that doesn't satisfy integer conditions
  # 
  # if in current task restriction j0 is d1 <= xj0 <= d2
  # in first splitted it will be         d1 <= xj0 <= [ xj0 ]
  # in second                            [xj0] + 1 <= xj0 <= d2
  # 
  # @return [Array<Hash>] hash format: { lower: [...], upper: [...] }
  def split_restrictions
    [
      modify_restrictions(first_noninteger_index, newupper: first_noninteger_var.truncate),
      modify_restrictions(first_noninteger_index, newlower: first_noninteger_var.truncate + 1)
    ]
  end

  # Modifies restriction on variable #idx with given values
  # returns new restrictions { lower: [....], upper: [...] }
  # options - hash { newlower: float, newupper: float }
  def modify_restrictions(idx, options = {})
    new_lower_value = options[:newlower]
    new_upper_value = options[:newupper]
    sign_restrictions.dup.tap do |restr|
      restr[:lower] = restr[:lower].dup.tap do |ary|
        ary[idx] = new_lower_value if new_lower_value
      end

      restr[:upper] = restr[:upper].dup.tap do |ary|
        ary[idx] = new_upper_value if new_upper_value
      end
    end
  end  
end
