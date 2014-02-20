module Statuses
  class BranchAndBound # has everything that simplex status has and a bit more (because branch and bounding includes simplex)
    include Statuses::Base

    set_statuses  :initialized => 'initialized',
      :optimal => 'optimal',
      :singular => 'matrix is singular',
      :unlimited => 'unlimited',
      :step_completed => 'step completed',
      :incompatible => 'incompatible constraints',
      :target_less_than_record => 'optimal plan less than record',
      :integer_solution_found => 'integer solution',
      :task_split => 'non integer solution, task split',
      :no_tasks => 'tasks list empty'

    set_finish_statuses :singular, :unlimited,
      :optimal, :no_tasks

    set_initial_status :initialized
  end
end
