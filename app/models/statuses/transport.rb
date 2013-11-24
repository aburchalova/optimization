module Statuses
  class Transport
    include Statuses::Base

    set_statuses  :initialized => 'initialized',
                  :incompatible => 'incompatible constraints',
                  :optimal => 'finished successfully',
                  :step_completed => 'step_completed'

    set_finish_statuses :optimal, :incompatible

    set_initial_status :initialized
  end
end
