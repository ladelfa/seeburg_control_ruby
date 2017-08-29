namespace :jukebox do
  desc "Turn jukebox power on"
  task power_up: :environment do
    Jukebox.power_up
  end

  desc "Turn jukebox power off immediately"
  task power_down: :environment do
    Jukebox.power_down true
  end

  desc "Reject currently playing record"
  task reject_record: :environment do
    Jukebox.reject_record
  end
end
