class UsbHidRelay
  VENDOR_ID = 0x16c0
  PRODUCT_ID = 0x05df

  RELAY_ON = 0xff
  RELAY_OFF = 0xfd

  REPORT_NBR = 0
  RELAY_COUNT = 2

  DEFAULT_MOMENTARY_MSECS = Settings.usb_hid_relay.default_momentary_msecs

  def self.enumerate
    HIDAPI::enumerate(VENDOR_ID, PRODUCT_ID)
  end

  def self.default_device
    return DummyRelayDevice.new if Settings.usb_hid_relay.use_dummy_relay
    enumerate.first
  end

  def initialize
    #
  end

  def device
    @device ||= self.class.default_device
  end

  def device=(d)
    @device = d
  end

  def toggle_relay(nbr, state)
    return unless nbr.in?(1..RELAY_COUNT)
    begin
      open
      device.write [ REPORT_NBR, (state ? RELAY_ON : RELAY_OFF), nbr ]
    rescue
    ensure
      close
    end
    state
  end

  def momentary_relay(nbr, ms = DEFAULT_MOMENTARY_MSECS)
    toggle_relay(nbr, true)
    sleep (ms * 0.001)
    toggle_relay(nbr, false)
  end

  def get_device_serial
    begin
      open
      rep = device.get_feature_report(REPORT_NBR)
    rescue
    ensure
      close
    end

    if rep
      rep[0..4]
    else
      nil
    end
  end

  def get_relay_states
    begin
      open
      rep = device.get_feature_report(REPORT_NBR)
    rescue
    ensure
      close
    end

    if rep
      states = rep.bytes.last
      RELAY_COUNT.times.map{|factor| states & (2**factor) > 0}
    else
      nil
    end
  end

  def get_relay_state(nbr)
    return nil unless nbr.in?(1..RELAY_COUNT)

    states = get_relay_states
    return nil if states.nil?

    states[nbr - 1]
  end

  def get_device_error
    message = nil

    if device.nil?
      message = "Nil device object"
    else
      begin
        device.open
        device.close
      rescue => e
        message = e.message
      ensure
        device.close rescue nil
      end
    end

    return message
  end

  def get_device_serial
    begin
      open
      rep = device.get_feature_report(REPORT_NBR)
    rescue
    ensure
      close
    end

    if rep
      rep[0..4]
    else
      nil
    end
  end


  private
    def open
      if device && !device.open?
        device.open rescue nil
      end
    end

    def close
      if device && device.open?
        device.close rescue nil
      end
    end

end