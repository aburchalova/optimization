# Real task is a LinearTask from which we're excluding artificial vars
# Result task doesn't contain artificial vars. It is initial task with some excluded rows
# jk is artificial index to remove from basis
#
class LinearConstraintRemover < Struct.new(:real_task, :result_task, :real_task_basis, :jk)

  def initialize(hash)
    super(*hash.values_at(*self.class.members))
  end

  # Remove i-th row from working matrix and b and
  # i: from 0 to m, m not included
  #
  def remove
    modify_tasks
    real_task_basis.delete(jk)
  end

  protected

  def modify_tasks
    LinearConstraintRemover.remove_row_from_task(real_task, linear_constraint_num)
    LinearConstraintRemover.remove_row_from_task(result_task, linear_constraint_num)
  end

  def linear_constraint_num
    @linear_constraint_num ||= jk - result_task.n
  end

  def self.remove_row_from_task(task, i)
    task.a = task.a.remove_row(i)
    task.b = (Matrix.from_gsl task.b).remove_row(i).gsl_matrix
  end
end
