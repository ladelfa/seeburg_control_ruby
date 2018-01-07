class PeriodicEventerJob < ApplicationJob
  queue_as :default

  def perform(seconds, class_name, callback_method, renewal_method)
    klass = class_name.constantize
    obj = klass.instance

    obj.send(callback_method)
    if obj.send(renewal_method)
      obj.callback_after_interval
    end
  end
end
