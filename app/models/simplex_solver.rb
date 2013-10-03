class SimplexSolver
  def initialize(task_with_plan)
    raise ArgumentError, 'Given plan is not a basis plan' unless task_with_plan.basis_plan?
    @task = task_with_plan
  end

  
end