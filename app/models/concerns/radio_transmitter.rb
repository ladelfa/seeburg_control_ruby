module RadioTransmitter
  PID_FILE = Settings.radio_transmitter.pid_file
  FM_FREQUENCY = Settings.radio_transmitter.fm_frequency
  RESTART_SLEEP = Settings.radio_transmitter.restart_sleep_secs

  def self.transmitter_command
    "(sox -t mp3 http://0.0.0.0:8080/stream.mp3 -t wav - | sudo /home/pi/PiFmRds/src/pi_fm_rds -freq #{FM_FREQUENCY} -pi '' -ps '' -rt '' -audio -) &"
  end

  def self.start
    return false if running?
    if pid = spawn(transmitter_command, out: "/tmp/radio_transmitter.out", err: "/tmp/radio_transmitter.err")
      File.write(PID_FILE, pid)
    end
    pid
  end

  def self.stop
    return false unless running?
    system "pkill -F #{PID_FILE}"
    system "pkill pi_fm_rds"
    system "pkill sox"
    File.delete(PID_FILE)   
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
  end
end
