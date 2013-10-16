module Statuses
  class SimplexFirstPhase
    include Statuses::Base

    set_statuses  :initialized => 'initialized',
                  :incompatible => 'incompatible constraints',
                  :linear_dependent => 'linear dependent constraints',
                  :got_task => 'finished successfully'

    set_finish_statuses :incompatible, :got_task

    set_initial_status :initialized
  end
end
