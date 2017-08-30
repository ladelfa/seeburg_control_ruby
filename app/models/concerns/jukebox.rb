class Jukebox
  include Singleton

  POWER_RELAY = Settings.jukebox.relay_number.power
  REJECT_RELAY = Settings.jukebox.relay_number.reject

  ADD_TIME_DEFAULT_MINUTES = Settings.jukebox.add_time.default_minutes

  SINGLE_RECORD_POWER_TIME = Settings.jukebox.single_record_play.power_secs
  SINGLE_RECORD_NEEDLE_TIME = Settings.jukebox.single_record_play.needle_secs

  STATES = [:off, :standby, :public_play, :home_play, :maintenance]
  STARTUP_STATUS = Settings.jukebox.startup_status

  attr_accessor :play_timer_guid, :status

  def initialize
    @relay_set = UsbHidRelay.new

    @public_server = PublicServer.new
    @needle_odometer = NeedleOdometer.instance

    @status = STARTUP_STATUS
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
      @public_server.update_status(new_status)
    end
  end

  def power_up
    @relay_set.toggle_relay(POWER_RELAY, true)
    @needle_odometer.start
    self.status = :public_play
    return powered?
  end

  def power_down(immediate = false)
    @relay_set.toggle_relay(POWER_RELAY, false)
    reject_record if immediate
    @needle_odometer.stop
    self.status = :standby
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
    self.play_timer_guid = PlayTimer.increment(secs, self.play_timer_guid) do
      power_down false
    end
    PlayTimer.time_remaining(self.play_timer_guid)
  end

  def time_remaining
    PlayTimer.time_remaining(self.play_timer_guid)
  end

  def clear_time
    PlayTimer.clear_time(self.play_timer_guid)
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
end
