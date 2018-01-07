class JukeboxController < ApplicationController
  def powerup
    Jukebox.power_up
    Jukebox.clear_time
    render plain: "Powering up and disabling play timer."
  end

  def powerdown_delayed
    Jukebox.power_down false
    Jukebox.clear_time
    render plain: "Powering down after current record finishes."
  end

  def powerdown_now
    Jukebox.power_down true
    Jukebox.clear_time
    render plain: "Powering down immediately."
  end

  def reject
    Jukebox.reject_record
    render plain: "Rejecting record."
  end

  def add_time
    duration = params[:seconds].presence || Jukebox::ADD_TIME_DEFAULT_MINUTES.minutes

    limit_time = true # TODO make this switchable

    if limit_time
      max_secs = Jukebox::PUBLIC_PLAY_MAXIMUM_SECS - Jukebox.time_remaining.ceil
      duration = [duration.to_i, max_secs].min
    end

    Jukebox.add_time(duration.to_i)
    render plain: "Enabling play timer and adding #{duration} seconds of play time."
  end

  def clear_time
    Jukebox.clear_time
    render plain: "Cleared play timer"
  end

  def get_minutes_remaining
    minutes = (Jukebox.time_remaining / 60).ceil
    render plain: minutes.to_s
  end

  def get_seconds_remaining
    seconds = Jukebox.time_remaining.ceil
    render plain: seconds.to_s
  end

  def set_status
    if params[:status].presence && params[:status].to_sym.in?(Jukebox::STATES)
      Jukebox.status = params[:status].to_sym
      render plain: "Set status '#{params[:status]}'"
    else
      render plain: "Invalid status '#{params[:status]}'"
    end
  end
end
