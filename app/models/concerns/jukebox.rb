class Jukebox
  include Singleton

  POWER_RELAY = 1
  REJECT_RELAY = 2

  attr_accessor :play_timer_guid

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

  def initialize
    @relay_set = UsbHidRelay.new
    @needle_counter = NeedleCounter.new
  end

  def power_up
    @relay_set.toggle_relay(POWER_RELAY, true)
    @needle_counter.start
    return powered?
  end

  def power_down(immediate = false)
    @relay_set.toggle_relay(POWER_RELAY, false)
    reject_record if immediate
    @needle_counter.stop
    return powered?
  end

  def powered?
    @relay_set.get_relay_state(POWER_RELAY)
  end

  def controllable?
    true
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
end
