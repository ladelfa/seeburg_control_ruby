class DummyRelayDevice
  def initialize
    @open = false
    @relay_states = [false, false]
  end

  def open
    @open = true
  end

  def open?
    @open
  end

  def close
    @open = false
  end

  def write(param_ary)
    report_nbr = param_ary[0]
    state_value = param_ary[1]
    relay_nbr = param_ary[2]

    case state_value
    when 0xff # on
      @relay_states[relay_nbr - 1] = true
    when 0xfd # off
      @relay_states[relay_nbr - 1] = false
    end
  end

  def get_feature_report(report_nbr)
    relay_byte = 0
    relay_byte += 1 if @relay_states[0]
    relay_byte += 2 if @relay_states[1]
    "DUMMY\x00\x00" + [relay_byte].pack("C")
  end
end
