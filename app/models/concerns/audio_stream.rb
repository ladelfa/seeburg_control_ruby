module AudioStream
  AUDIO_STREAM_PORT = Settings.audio_stream.port
  PID_FILE = Settings.audio_stream.vlc.pid_file
  RESTART_SLEEP = Settings.audio_stream.restart_sleep_secs
  AVERAGE_BITRATE = Settings.audio_stream.vlc.average_bitrate
  SAMPLERATE = Settings.audio_stream.vlc.sample_rate
  CHANNELS = Settings.audio_stream.vlc.channels

  def self.current_audio_connection_count
    `netstat -anp 2> /dev/null | grep :#{AUDIO_STREAM_PORT} | grep ESTABLISHED | wc -l`.to_i
  end

  def self.streaming_command
    "cvlc alsa://default -L -Z --sout-keep " +
      "--daemon --pidfile #{PID_FILE} " +
      "--sout '#transcode{vcodec=none,acodec=mp3,ab=#{AVERAGE_BITRATE},channels=#{CHANNELS},samplerate=#{SAMPLERATE}}:" +
      "duplicate{dst=display{delay=1000},dst=gather:std{mux=raw,dst=:#{AUDIO_STREAM_PORT}/stream.mp3,access=http},select=\"novideo\"}'"
  end

  def self.start
    return false if running?
    system streaming_command
  end

  def self.stop
    return false unless running?
    system "pkill -F #{PID_FILE}"
  end

  def self.running?
    File.exists?(PID_FILE)
  end

  def self.restart
    stop
    sleep RESTART_SLEEP
    start
  end
end
