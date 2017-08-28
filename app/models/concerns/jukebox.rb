class Jukebox
  POWER_RELAY = 1
  REJECT_RELAY = 2

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
end
