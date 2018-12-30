class AdminController < ActionController::Base
  before_action :set_assigns

  def index
  end

  def current_stats
    render partial: 'current_stats', layout: false
  end

  private
    def set_assigns
      @jukebox = Jukebox
      @usb_hid_relay = UsbHidRelay.new
      @needle_odometer = NeedleOdometer
      @audio_stream = AudioStream
      @audio_stream_monitor = AudioStreamMonitor
      @radio_transmitter = RadioTransmitter
    end
end