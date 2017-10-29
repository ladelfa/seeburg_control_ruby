class RadioTransmitter < PeriodicEventer
  include Singleton

  PID_FILE = Settings.radio_transmitter.pid_file
  DEFAULT_FM_FREQUENCY = Settings.radio_transmitter.fm_frequency
  RESTART_SLEEP = Settings.radio_transmitter.restart_sleep_secs
  FREQUENCY_RANGE = (87.5..108.0)

  def initialize
    @frequency = DEFAULT_FM_FREQUENCY
    super
  end

  def transmitter_command
    "(sox -t mp3 http://0.0.0.0:8080/stream.mp3 -t wav - | sudo /home/pi/PiFmRds/src/pi_fm_rds -freq #{@frequency} -pi '' -ps '' -rt '' -audio -) &"
  end

  def start
    return false if running?
    if pid = spawn(transmitter_command, out: "/tmp/radio_transmitter.out", err: "/tmp/radio_transmitter.err")
      File.write(PID_FILE, pid)
      return pid
    else
      return nil
    end

  end

  def stop
    return false unless running?
    system "pkill -F #{PID_FILE}"
    system "pkill pi_fm_rds"
    system "pkill sox"
    File.delete(PID_FILE)
  end

  def running?
    File.exists?(PID_FILE)
  end

  def pid
    if File.exists?(PID_FILE)
      File.read(PID_FILE)
    else
      ''
    end
  end

  def restart
    stop
    sleep RESTART_SLEEP
    start
  end

  def frequency
    @frequency
  end

  def frequency=(input)
    if FREQUENCY_RANGE.include?(input.to_f)
      @frequency = input.to_f
    end
    @frequency
  end

  def self.method_missing(m,*a,&b)    # :nodoc:
    if instance.respond_to?(m)
      instance.send(m,*a,&b)
    else
      # no super available for modules.
      raise NoMethodError, "undefined method `#{m}` for Jukebox"
    end
  end

  def self.respond_to_missing?(m, a)     # :nodoc:
    instance.respond_to?(m)
  end
end
