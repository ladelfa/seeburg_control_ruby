require "config"

if Settings.audio_stream.restart_on_boot
  puts "Restarting Audio Stream ..."
  AudioStream.restart
else
  if AudioStream.running?
    puts "Audio Stream seems to be running"
  else
    puts "Audio Stream seems not to be running"
  end
end
