class AdminController < ActionController::Base
  def index
    @jukebox = Jukebox
    @usb_hid_relay = UsbHidRelay.new
    @needle_odometer = NeedleOdometer
    @audio_stream = AudioStream
  end
end