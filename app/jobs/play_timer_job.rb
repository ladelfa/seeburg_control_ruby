class PlayTimerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    guid = args[0]
    PlayTimer.check_time guid
  end
end
