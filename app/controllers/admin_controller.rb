class AdminController < ActionController::Base
  def index
    @jukebox = Jukebox
    @usb_hid_relay = UsbHidRelay.new
    @needle_odometer = NeedleOdometer
    @audio_stream = AudioStream
    @audio_stream_monitor = AudioStreamMonitor
    @radio_transmitter = RadioTransmitter
  end
end