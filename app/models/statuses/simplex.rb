module Statuses
  class Simplex
    include Statuses::Base

    set_statuses  :initialized => 'initialized',
      :optimal => 'optimal',
      :singular => 'matrix is singular',
      :unlimited => 'unlimited',
      :step_completed => 'step completed',
      :not_a_plan => 'given vector is not a plan',
      :incompatible => 'incompatible constraints'

    set_finish_statuses :singular, :unlimited,
      :optimal, :not_a_plan, :incompatible

    set_initial_status :initialized
  end
end
