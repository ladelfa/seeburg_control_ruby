class AudioStream
  AUDIO_STREAM_PORT = 8080

  def self.current_audio_connection_count
    `netstat -anp 2> /dev/null | grep :#{AUDIO_STREAM_PORT} | grep ESTABLISHED | wc -l`.to_i
  end

  def self.start_streaming
    # TEMP
    `cvlc ~/sound_test/canto_ostinato/*.mp3 -L -Z --sout-keep --sout '#transcode{vcodec=none,acodec=mp3,ab=96,channels=2,samplerate=44100}:duplicate{dst=display{delay=1000},dst=gather:std{mux=raw,dst=:#{AUDIO_STREAM_PORT}/stream.mp3,access=http},select="novideo"}'`
  end
end
