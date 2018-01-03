class PlayTimer < PeriodicEventer
  include Singleton

  MONITOR_INTERVAL_SECS = Settings.jukebox.play_timer.monitor_interval_secs

  attr_accessor :expiration
  attr_accessor :on_timeout_block

  def self.method_missing(m,*a,&b)    # :nodoc:
    if instance.respond_to?(m)
      instance.send(m,*a,&b)
    else
      # no super available for modules.
      raise NoMethodError, "undefined method `#{m}` for PlayTimer"
    end
  end

  def self.respond_to_missing?(m, a)     # :nodoc:
    instance.respond_to?(m)
  end

  def initialize
    @expiration = nil
    @on_timeout_block = nil
  end

  def increment(seconds, &on_timeout_block)
    start(MONITOR_INTERVAL_SECS) unless running?
    @on_timeout_block = on_timeout_block

    base_dt = @expiration
    base_dt = Time.now if (base_dt.nil? || base_dt.past?)
    @expiration = base_dt + seconds
  end

  def time_remaining
    return 0.0 if @expiration.nil?
    @expiration - Time.now
  end

  def clear_time
    @expiration = nil
    0
  end

  def callback # This gets called every MONITOR_INTERVAL_SECS seconds
    if time_remaining <= 0
      puts "#{Time.now} Time's up"

      stop
      clear_time
      on_timeout_block.call
    else
      puts "#{Time.now} Time's not yet up (#{time_remaining} remaining)"
    end
  end
end
