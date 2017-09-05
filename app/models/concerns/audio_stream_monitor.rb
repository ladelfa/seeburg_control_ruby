class AudioStreamMonitor < PeriodicEventer
  def initialize
    @last_connection_at = nil
    super
  end

  def start(*args)
    @last_connection_at = Time.now
    super
  end

  def callback
    #puts "Count #{AudioStream.current_audio_connection_count}"
    @last_connection_at = Time.now if (AudioStream.current_audio_connection_count > 0)
    #puts "LCA #{@last_connection_at}"

    if Settings.jukebox.require_audio_connection.enabled && (last_connection_ago >= Settings.jukebox.require_audio_connection.timeout_secs)
      Jukebox.power_down true
    end
  end

  def last_connection_at
    @last_connection_at
  end

  def last_connection_ago
    return 0 if @last_connection_at.nil?
    Time.now - @last_connection_at
  end

end
