module AudioStream
  AUDIO_STREAM_PORT = 8080
  PID_FILE = "/tmp/vlc.pid"
  RESTART_SLEEP = 2

  def self.current_audio_connection_count
    `netstat -anp 2> /dev/null | grep :#{AUDIO_STREAM_PORT} | grep ESTABLISHED | wc -l`.to_i
  end

  def self.streaming_command
    "cvlc /home/pi/sound_test/canto_ostinato/*.mp3 -L -Z --sout-keep " +
      "--daemon --pidfile #{PID_FILE} " +
      "--sout '#transcode{vcodec=none,acodec=mp3,ab=96,channels=2,samplerate=44100}:" +
      "duplicate{dst=display{delay=1000},dst=gather:std{mux=raw,dst=:#{AUDIO_STREAM_PORT}/stream.mp3,access=http},select=\"novideo\"}'"
  end

  def self.start
    return false if File.exists?(PID_FILE)
    system streaming_command
  end

  def self.stop
    return false unless File.exists?(PID_FILE)
    system "pkill -F #{PID_FILE}"
  end

  def self.restart
    stop
    sleep RESTART_SLEEP
    start
  end
end
