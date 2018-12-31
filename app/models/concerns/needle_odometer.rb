class NeedleOdometer
  include Singleton

  attr_accessor :last_value, :value_last_updated_at, :running
  attr_accessor :state

  PERIODICALLY_PERSIST = Settings.needle_odometer.periodically_persist
  PERISTANCE_INTERVAL_SECS = Settings.needle_odometer.peristance_interval_secs

  PERIODICALLY_LOG = Settings.needle_odometer.periodically_log
  LOG_INTERVAL_SECS = Settings.needle_odometer.log_interval_secs
  LOG_ON_START = Settings.needle_odometer.log_on_start
  EXPORT_ON_LOG = Settings.needle_odometer.export_on_log

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
      load
      @running = true
      periodically_persist! if PERIODICALLY_PERSIST
      persist

      if LOG_ON_START
        if PERIODICALLY_LOG
          periodically_log!("start")
        else
          log("start")
        end
      end
    end
  end

  def stop
    if running?
      persist
      @running = false
      #log("stop") # We don't really need this one.
    end
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
    File.write(persistance_filename, '0.0')
    @value_last_updated_at = Time.now
    @last_value = 0
  end

  def load
    if File.exists?(persistance_filename)
      @last_value = File.read(persistance_filename).to_f
    else
      @last_value = 0
    end
    @value_last_updated_at = Time.now
    @last_value
  end

  def persist
    val = current_value
    File.write(persistance_filename, val.to_s)
    #puts "#{self.object_id} persisting needle time #{val} " + (@running ? "Running" : "Not running")
    val
  end

  def periodically_persist!
    #puts "pp! #{last_value}"
    persist
    if running?
      #puts "Queuing a new NeedleOdometerJob job"
      NeedleOdometerJob.set(wait: PERISTANCE_INTERVAL_SECS).perform_later('persist')
    end
  end

  def log(tag = "")
    val = current_value
    line = "#{Time.now.to_s(:iso)}\t#{val.to_i}\t#{tag}\n"
    File.write(history_log_filename, line, mode: 'a')

    PublicServer.export_needle_odometer(val) if EXPORT_ON_LOG
  end

  def periodically_log!(tag = "")
    log(tag)
    if running?
      NeedleOdometerJob.set(wait: LOG_INTERVAL_SECS).perform_later('log')
    end
  end

  def persistance_filename
    File.join(Rails.root, "db", "needle_time.txt")
  end

  def history_log_filename
    File.join(Rails.root, "db", "needle_time_history.txt")
  end

end