class AudioStreamMonitor < PeriodicEventer
  include Singleton

  def initialize
    @@last_connection_at = nil
    self.require_audio_connection = Settings.jukebox.require_audio_connection.enabled
    super
  end

  def start(*args)
    @@last_connection_at = Time.now
    super
  end

  def callback
    #puts "Count #{AudioStream.current_audio_connection_count}"
    @@last_connection_at = Time.now if (AudioStream.current_audio_connection_count > 0)
    #puts "LCA #{@last_connection_at}"

    if require_audio_connection? && (last_connection_ago >= require_audio_connection_timeout_secs)
      Jukebox.power_down true
    end
  end

  def last_connection_at
    @@last_connection_at
  end

  def last_connection_ago
    return 0 if @@last_connection_at.nil?
    Time.now - @@last_connection_at
  end

  def require_audio_connection?
    @@require_audio_connection
  end

  def require_audio_connection=(bool)
    @@require_audio_connection = !!bool
  end

  def require_audio_connection_timeout_secs
    Settings.jukebox.require_audio_connection.timeout_secs
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
