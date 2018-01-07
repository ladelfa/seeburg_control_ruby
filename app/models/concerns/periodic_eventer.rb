class PeriodicEventer
  include Singleton

  def initialize
    @running = false
    @interval = 1
  end

  def interval=(seconds)
    @interval = seconds
  end

  def start(interval = nil)
    @interval = interval.to_f
    @running = true
    callback_after_interval
  end

  def callback_after_interval
    PeriodicEventerJob.set(wait: @interval).perform_later(@interval, self.class.name, 'callback', 'running?')
  end

  def stop
    @running = false
  end

  def running?
    @running
  end

  # Subclass should implement this
  def callback
    puts "callbacked"
  end
end