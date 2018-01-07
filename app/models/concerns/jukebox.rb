class Jukebox
  include Singleton

  POWER_RELAY = Settings.jukebox.relay_number.mech_power
  REJECT_RELAY = Settings.jukebox.relay_number.scan_reject

  ADD_TIME_DEFAULT_MINUTES = Settings.jukebox.add_time.default_minutes
  PUBLIC_PLAY_MAXIMUM_SECS = Settings.jukebox.public_play.maximum_secs

  SINGLE_RECORD_POWER_TIME = Settings.jukebox.single_record_play.power_secs
  SINGLE_RECORD_NEEDLE_TIME = Settings.jukebox.single_record_play.needle_secs

  RUNOUT_SAVER_ENABLED = Settings.jukebox.runout_saver.enabled
  RUNOUT_SAVER_TIMEOUT = Settings.jukebox.runout_saver.delay_secs

  STATES = [:off, :standby, :public_play, :home_play, :maintenance]
  STARTUP_STATUS = Settings.jukebox.startup_status

  AUDIO_STREAM_MONITOR_INTERVAL = Settings.jukebox.require_audio_connection.monitor_interval_secs

  attr_accessor :status

  def initialize
    @relay_set = UsbHidRelay.new
    @needle_odometer = NeedleOdometer.instance
    @audio_stream_monitor = AudioStreamMonitor.instance
    @runout_saver = RunoutSaver.instance
    @play_timer = PlayTimer.instance
  end

  def public_controllable?
    @status.in? [:standby, :public_play]
  end

  def private_controllable?
    true
  end

  def status=(new_status)
    new_status = new_status.to_sym
    if new_status.in?(STATES)
      @status = new_status
      PublicServer.update_status(new_status)
    end
  end

  def power_up
    unless powered?
      @relay_set.toggle_relay(POWER_RELAY, true)
      @needle_odometer.start
      self.status = :public_play
      @audio_stream_monitor.start(AUDIO_STREAM_MONITOR_INTERVAL)
      return powered?
    end
  end

  def power_down(immediate = false)
    @relay_set.toggle_relay(POWER_RELAY, false)
    reject_record if immediate
    clear_time
    @needle_odometer.stop
    self.status = :standby
    @audio_stream_monitor.stop
    @runout_saver.start(RUNOUT_SAVER_TIMEOUT) if RUNOUT_SAVER_ENABLED
    return !powered?
  end

  def powered?
    @relay_set.get_relay_state(POWER_RELAY)
  end

  def play_single_record
    # momentary_relay takes time in milliseconds
    @relay_set.momentary_relay(POWER_RELAY, SINGLE_RECORD_POWER_TIME * 1000)
    self.status = :standby
    @needle_odometer.increment(SINGLE_RECORD_NEEDLE_TIME)
    return true
  end

  def reject_record
    @relay_set.momentary_relay(REJECT_RELAY)
    nil
  end

  def add_time(secs)
    power_up
    @play_timer.increment(secs) do
      power_down(false) if powered?
    end
    @play_timer.time_remaining
  end

  def time_remaining
    @play_timer.time_remaining
  end

  def clear_time
    @play_timer.clear_time
  end

  def self.method_missing(m,*a,&b)    # :nodoc:
    if instance.respond_to?(m)
      instance.send(m,*a,&b)
    else
      # no super available for modules.
      raise NoMethodError, "undefined method `#{m}` for Jukebox"
    end
  end

  def self.respond_to_missing?(m, a)     # :nodoc:
    instance.respond_to?(m)
  end

  def self.on_launch
    instance.status = STARTUP_STATUS
  end
end
