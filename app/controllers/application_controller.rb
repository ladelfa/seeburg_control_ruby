class ApplicationController < ActionController::API
  def test
    render plain: "OK"
  end

  def version
    render plain: UsbHidRelay.new.get_device_serial
  end

  def get_current_audio_connections
    # returns newline-separated list of current connection IP addresses
  end

  def get_current_audio_connection_count
    render plain: AudioStream.current_audio_connection_count.to_s
  end

  def restart_audio_stream
    AudioStream.restart
    render plain: "Audio stream has been restarted."
  end

  def start_radio_transmitter
    RadioTransmitter.frequency = params[:freq] if params[:freq].presence
    RadioTransmitter.restart
    render plain: "Radio transmitter has been restarted on #{RadioTransmitter.frequency} MHz."
  end

  def stop_radio_transmitter
    RadioTransmitter.stop
    render plain: "Radio transmitter has been stopped."
  end

  def require_audio_connection
    AudioStreamMonitor.require_audio_connection = true
    render plain: "Requiring audio connection every #{AudioStreamMonitor.require_audio_connection_timeout_secs} seconds"
  end

  def dont_require_audio_connection
    AudioStreamMonitor.require_audio_connection = false
    render plain: "Audio connection not required for playback to continue"
  end

  def drop_audio_connections_to
    # TODO
  end
end
