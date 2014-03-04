module Statuses
  class Gomori
    include Statuses::Base

    set_statuses  :initialized => 'initialized',
      :optimal => 'optimal',
      :singular => 'matrix is singular',
      :unlimited => 'unlimited',
      :step_completed => 'step completed',
      :incompatible => 'incompatible constraints',
      :inner_error => 'simplex solver couldnt solve artificial task',
      :integer_solution => 'finished successfully'

    set_finish_statuses :singular, :unlimited, # from simplex
      :integer_solution, # ending
      :incompatible, :inner_error # from first phase simplex

    set_initial_status :initialized
  end
end
