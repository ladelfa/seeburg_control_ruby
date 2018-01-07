class NeedleOdometer
  include Singleton

  attr_accessor :last_value, :value_last_updated_at, :running
  attr_accessor :state

  PERIODICALLY_PERSIST = Settings.needle_odometer.periodically_persist
  PERISTANCE_INTERVAL_SECS = Settings.needle_odometer.peristance_interval_secs

  def self.method_missing(m,*a,&b)    # :nodoc:
    if instance.respond_to?(m)
      instance.send(m,*a,&b)
    else
      # no super available for modules.
      raise NoMethodError, "undefined method `#{m}` for NeedleOdometer"
    end
  end

  def self.respond_to_missing?(m, a)     # :nodoc:
    instance.respond_to?(m)
  end

  def initialize
    @running = false
    load
  end

  def start
    unless running?
      @running = true
      periodically_persist! if PERIODICALLY_PERSIST
      persist
    end
  end

  def stop
    persist
    @running = false
  end

  def running?
    @running
  end

  def current_value
    running? ? update : @last_value
  end

  def update
    now = Time.now
    elapsed = Time.now - @value_last_updated_at
    @last_value += elapsed
    @value_last_updated_at = now
    @last_value
  end

  def increment(secs)
    @last_value += secs
  end

  # Only do this when installing fresh stylii
  def reset!
    File.write(filename, '0.0')
    @value_last_updated_at = Time.now
    @last_value = 0
  end

  def load
    if File.exists?(filename)
      @last_value = File.read(filename).to_f
    else
      @last_value = 0
    end
    @value_last_updated_at = Time.now
    @last_value
  end

  def persist
    val = current_value
    File.write(filename, val.to_s)
    #puts "#{self.object_id} persisting needle time #{val} " + (@running ? "Running" : "Not running")
    val
  end

  def periodically_persist!
    #puts "pp! #{last_value}"
    persist
    if running?
      #puts "Queuing a new NeedleOdometerJob job"
      NeedleOdometerJob.set(wait: PERISTANCE_INTERVAL_SECS).perform_later()
    end
  end

  def filename
    File.join(Rails.root, "db", "needle_time.txt")
  end
end