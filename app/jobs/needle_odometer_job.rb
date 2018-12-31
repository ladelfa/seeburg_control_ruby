class NeedleOdometerJob < ApplicationJob
  queue_as :default

  def perform(action)
    case action.to_sym
    when :persist
      NeedleOdometer.instance.periodically_persist!
    when :log
      NeedleOdometer.instance.periodically_log!
    end
  end
end
