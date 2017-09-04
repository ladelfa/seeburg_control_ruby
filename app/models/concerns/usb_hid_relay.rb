class UsbHidRelay
  VENDOR_ID = 0x16c0
  PRODUCT_ID = 0x05df

  RELAY_ON = 0xff
  RELAY_OFF = 0xfd

  REPORT_NBR = 0
  RELAY_COUNT = 2

  DEFAULT_MOMENTARY_MSECS = Settings.usb_hid_relay.default_momentary_msecs

  attr_accessor :device

  def self.enumerate
    HIDAPI::enumerate(VENDOR_ID, PRODUCT_ID)
  end

  def self.default_device
    return DummyRelayDevice.new if Settings.usb_hid_relay.use_dummy_relay
    enumerate.first
  end

  def initialize
    if (dev = self.class.default_device)
      @device = dev
    end
  end

  def toggle_relay(nbr, state)
    return unless nbr.in?(1..RELAY_COUNT)
    begin
      @device.open
      @device.write [ REPORT_NBR, (state ? RELAY_ON : RELAY_OFF), nbr ]
    ensure
      @device.close
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
      @device.open
      rep = @device.get_feature_report(REPORT_NBR)
    ensure
      @device.close
    end

    if rep
      rep[0..4]
    else
      nil
    end
  end

  def get_relay_states
    begin
      @device.open
      rep = @device.get_feature_report(REPORT_NBR)
    ensure
      @device.close
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
    get_relay_states[nbr - 1]
  end

  private
    def open
      if @device && !@device.open?
        @device.open
      end
    end

    def close
      if @device && @device.open?
        @device.close
      end
    end

=begin
  def config
    {
      vendor_id: VENDOR_ID,
      product_id: 0x05df,
      serial_number: '123456',
      simple_name: 'usb_hid_two_relay_board',
      bus_number: 1,
      device_address: 5,
      interface: 0
    }
  end

  def setup!
    HIDAPI::SetupTaskHelper.new(
      config[:vendor_id],
      config[:product_id],
      config[:simple_name],
      config[:interface]
    ).run
  end

  def open
    @device = HIDAPI::open(config[:vendor_id], config[:product_id])
  end

  def close
    @device.close
  end
=end
end