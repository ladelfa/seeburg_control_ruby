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

end
