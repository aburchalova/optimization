module Statuses
  class Quadro
    include Statuses::Base

    set_statuses  :initialized => 'initialized',
      :optimal => 'optimal',
      :singular => 'matrix is singular',
      :unlimited => 'unlimited',
      :step_completed => 'step completed',
      :incompatible => 'incompatible constraints',
      :recalculating_step => 'gone for small iteration, recalculating direction'

    set_finish_statuses :singular, :unlimited,
      :optimal, :incompatible

    set_initial_status :initialized
  end
end
