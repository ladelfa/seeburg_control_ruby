class RunoutSaver < PeriodicEventer
  def callback
    if Jukebox.powered?
      puts "RunoutSaver: Not rejecting record because jukebox is currently powered up"
    else
      puts "RunoutSaver: rejecting record"
      Jukebox.reject_record
    end
    stop # Only perform this callback once per start cycle.
  end
end
