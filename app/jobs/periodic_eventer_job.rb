class PeriodicEventerJob < ApplicationJob
  queue_as :default

  def perform(seconds, class_name, callback_method, renewal_method)
    klass = class_name.constantize
    obj = klass.instance

    while obj.send(renewal_method) do
      obj.send(callback_method)
      sleep(seconds) if obj.send(renewal_method)
    end
  end
end
