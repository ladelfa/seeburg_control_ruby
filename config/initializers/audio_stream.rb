require "config"

if AudioStream.running?
  puts "Audio Stream seems to be running as PID #{AudioStream.pid}"
else
  puts "Audio Stream seems not to be running"
end

if Settings.audio_stream.restart_on_boot
  puts "Restarting Audio Stream ..."
  AudioStream.restart

  if AudioStream.running?
    puts "Audio Stream seems to now be running as PID #{AudioStream.pid}"
  else
    puts "Audio Stream seems not to be running"
  end
end

