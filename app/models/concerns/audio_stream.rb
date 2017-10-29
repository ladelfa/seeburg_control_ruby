module AudioStream
  ALSA_INPUT_DEVICE = Settings.audio_stream.alsa.input_device
  #ALSA_OUTPUT_DEVICE = Settings.audio_stream.alsa.output_device
  AUDIO_STREAM_PORT = Settings.audio_stream.port
  AUDIO_STREAM_PATH = Settings.audio_stream.path
  PID_FILE = Settings.audio_stream.vlc.pid_file
  RESTART_SLEEP = Settings.audio_stream.restart_sleep_secs
  AVERAGE_BITRATE = Settings.audio_stream.vlc.average_bitrate
  SAMPLERATE = Settings.audio_stream.vlc.sample_rate
  CHANNELS = Settings.audio_stream.vlc.channels
  RESTART_ON_LAUNCH = Settings.audio_stream.restart_on_launch

  def self.current_audio_connection_count
    `netstat -anp 2> a/dev/null | grep :#{AUDIO_STREAM_PORT} | grep ESTABLISHED | wc -l`.to_i
  end

  def self.current_audio_connections
    # e.g. ["tcp", "0", "9407", "192.168.2.164:8080", "192.168.2.173:58718", "ESTABLISHED", "14031/vlc"]
    connection_col = 4

    res = %x(netstat -anp 2> /dev/null | grep :#{AUDIO_STREAM_PORT} | grep ESTABLISHED)
    res.split("\n").map{|line| line.split(" ")[connection_col]}
  end

  def self.streaming_command
    "cvlc alsa://#{ALSA_INPUT_DEVICE} -L -Z --sout-keep " +
      "--daemon --pidfile #{PID_FILE} " +
      "--sout '#transcode{vcodec=none,acodec=mp3,ab=#{AVERAGE_BITRATE},channels=#{CHANNELS},samplerate=#{SAMPLERATE}}:" +
      "duplicate{dst=display{novideo=true},dst=gather:std{mux=raw,dst=:#{AUDIO_STREAM_PORT}#{AUDIO_STREAM_PATH},access=http},select=\"novideo\"}'"
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

  def self.pid
    if File.exists?(PID_FILE)
      File.read(PID_FILE)
    else
      ''
    end
  end

  def self.restart
    stop
    sleep RESTART_SLEEP
    start
  end

  def self.on_launch
    if running?
      puts "Audio Stream seems to be running as PID #{AudioStream.pid}"
    else
      puts "Audio Stream seems not to be running"
    end

    if RESTART_ON_LAUNCH
      puts "Restarting Audio Stream ..."
      restart

      if running?
        puts "Audio Stream seems to now be running as PID #{AudioStream.pid}"
      else
        puts "Audio Stream seems not to be running"
      end
    end
  end
end
