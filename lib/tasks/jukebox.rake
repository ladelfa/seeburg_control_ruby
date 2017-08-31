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

  desc "Play a single record"
  task play_single: :environment do
    Jukebox.play_single_record
  end

  desc "Put jukebox in 'maintenace' mode"
  task maintenance: :environment do
    Jukebox.status = :maintenance
  end

  desc "Put jukebox in 'off' mode"
  task off: :environment do
    Jukebox.status = :off
  end

  desc "Put jukebox in 'standby' mode"
  task standby: :environment do
    Jukebox.status = :standby
  end

  desc "Set jukebox URL on public server"
  task set_jukebox_url: :environment do
    PublicServer.update_jukebox_url
  end
end
