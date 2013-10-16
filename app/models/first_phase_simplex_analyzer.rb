class FirstPhaseSimplexAnalyzer

  attr_accessor :task, :status, :artificial_task


  # @param task [LinearTask]
  #
  def initialize(task)
    @task = task
    @status = Statuses::SimplexFirstPhase.new
  end

  def analyze
    return if status.finished?
    widen_basis
  end

  def widen_basis
    widen_matrix
    widen_c
  end

  def widen_matrix
    @new_width = task.a.m + task.a.n
    eye = GSL::Matrix.eye(task.a.m)
    @new_a = task.a.horzcat(eye)
  end

  def widen_c

  end
end