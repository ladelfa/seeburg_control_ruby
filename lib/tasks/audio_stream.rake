namespace :audio_stream do
  desc "Start Audio Stream"
  task start: :environment do
    AudioStream.start
  end

  desc "Stop Audio Stream"
  task stop: :environment do
    AudioStream.stop
  end

  desc "Restart Audio Stream"
  task restart: :environment do
    AudioStream.restart
  end

  desc "Show Audio Stream command"
  task show_command: :environment do
    puts AudioStream.streaming_command
  end

  desc "Show current Audio Stream PID"
  task show_pid: :environment do
    puts AudioStream.pid
  end

end
