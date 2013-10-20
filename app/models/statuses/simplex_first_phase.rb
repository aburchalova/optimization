module Statuses
  class SimplexFirstPhase
    include Statuses::Base

    set_statuses  :initialized => 'initialized',
                  :incompatible => 'incompatible constraints',
                  :linear_dependent => 'linear dependent constraints',
                  :got_task => 'finished successfully',
                  :removed_art_variable => 'removed artificial variable',
                  :inner_error => 'simplex solver couldnt solve artificial task'

    set_finish_statuses :got_task, :inner_error, :incompatible

    set_initial_status :initialized
  end
end
