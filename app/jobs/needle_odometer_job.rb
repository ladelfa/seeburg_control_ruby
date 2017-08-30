class NeedleOdometerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    NeedleOdometer.instance.periodically_persist!
  end
end
