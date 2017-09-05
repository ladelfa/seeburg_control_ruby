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
    PeriodicEventerJob.set(wait: @interval).perform_later(@interval, self.class.name, 'callback', 'running?')
  end

  def stop
    @running = false
  end

  def running?
    @running
  end

  def callback
    puts "callbacked"
  end
end