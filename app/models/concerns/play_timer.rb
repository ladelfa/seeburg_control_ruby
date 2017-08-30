class PlayTimer
  include Singleton

  # Hash, e.g. {"cff9aa8c-99a6-4ac5-898d-44f15e9be961"=>2017-08-28 17:23:49 -0700}
  attr_accessor :expirations
  attr_accessor :callbacks

  def self.method_missing(m,*a,&b)    # :nodoc:
    if instance.respond_to?(m)
      instance.send(m,*a,&b)
    else
      # no super available for modules.
      raise NoMethodError, "undefined method `#{m}` for PlayTimer"
    end
  end

  def self.respond_to_missing?(m, a)     # :nodoc:
    instance.respond_to?(m)
  end

  def initialize
    @expirations = {}
    @callbacks = {}
  end

  def increment(seconds, guid = nil, &callback)
    guid =  SecureRandom.uuid if guid.nil?

    @callbacks[guid.to_s] = callback

    base_dt = @expirations[guid.to_s]
    base_dt = Time.now if (base_dt.nil? || base_dt.past?)
    new_expiration = base_dt + seconds

    @expirations[guid.to_s] = new_expiration
    PlayTimerJob.set(wait_until: new_expiration).perform_later(guid.to_s)
    guid
  end

  def time_remaining(guid)
    return 0.0 if @expirations[guid.to_s].nil?
    @expirations[guid.to_s] - Time.now
  end

  def clear_time(guid)
    @expirations.delete guid
    0
  end

  def check_time(guid)
    if time_remaining(guid) <= 0
      #puts "#{guid} #{Time.now} Times up"
      clear_time(guid)
      do_callback(guid)
    else
      #puts "#{guid} #{Time.now} Time's not yet up"
    end
  end

  def do_callback(guid)
    #puts "CALLBACK #{guid}"
    @callbacks[guid.to_s].call
  end
end
