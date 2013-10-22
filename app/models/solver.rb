module Solver
  extend ActiveSupport::Concern

  include NewTaskComposing

  attr_accessor :task, :status, :logging
  delegate :optimal?, :finished?, :to => :status

  def initialize(task_with_plan)
    @initial_task = task_with_plan
    @task = task_with_plan
    @status = Statuses::Simplex[:initialized]
    @logging = false
    self
  end

  def step
    calculate_and_change_status
    new_task = compose_new_task
    calculate_target_function_delta(new_task)
    log_stats
    set_new_task(new_task)
    self
  end

  def calculate_and_change_status
    raise "calculate_and_change_status should be implemented in #{self.class}"
  end

  def iterate
    step until finished?
  end

  def result
    iterate
    status.data = optimal? ? task.plan : nil 
    status
  end

  def result_plan
    iterate
    optimal? && task.plan || nil
  end

  def result_ary
    iterate
    optimal? && task.plan.x_ary || nil
  end

  def to_s
    %Q(
--------SIMPLEX SOLVER-----STATUS: #{status}----------------------
      #{initial_status}
      #{step_description}
      #{target_delta}
-------------------------------------------------------------)
  end

  module ClassMethods
    def simple_init(a, b, c, plan, basis)
      task = LinearTask.new(:a => a, :b => b, :c => c)
      x = BasisPlan.new(plan, basis)
      new(LinearTaskWithBasis.new(task, x))
    end
  end

  protected

  def set_new_task(new_task)
    @task = new_task
  end

  def log_stats
    puts self if logging
  end

  def calculate_target_function_delta(new_task)
    @target_function_delta = new_task.target_function - task.target_function
  end

  def initial_status
    return unless @status.initialized?
%Q(
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #{task.task.to_s}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~)
  end

  def target_delta
    return unless @status.step_completed?
    "Target function delta: #{@target_function_delta}\n"
  end

  def step_description
    return if @status.initialized?
    task.to_s
  end
end