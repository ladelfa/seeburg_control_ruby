class JukeboxController < ApplicationController
  before_action :get_jukebox

  def powerup
    @jukebox.power_up
    render plain: "Powering up and disabling play timer."
  end

  def powerdown_delayed
    @jukebox.power_down false
    render plain: "Powering down after current record finishes."
  end

  def powerdown_now
    @jukebox.power_down true
    render plain: "Powering down immediately."
  end

  def reject
    @jukebox.reject_record
    render plain: "Rejecting record."
  end

  def add_time
  end

  def get_minutes_remaining
    # m_oPlayTimer.MinutesLeft
  end

  def get_current_audio_connections
    # returns newline-separated list of current connection IP addresses
  end

  def get_current_audio_connection_count
    # returns int
  end

  def drop_audio_connections_to
    # TODO
  end

  private
    def get_jukebox
      @jukebox = Jukebox.new
    end

=begin
    Select Case tRequest
      Case "/reject"
        If bMachineIsControllable Then
          tResponse = "Rejecting record."
          RejectRecord()
        Else
          tResponse = "Machine cannot be controlled at this time."
        End If

      Case "/powerup"
        If bMachineIsControllable Then
          tResponse = "Powering up and disabling play timer."
          PowerUpAndDisableTimer()
        Else
          tResponse = "Machine cannot be controlled at this time."
        End If

      Case "/powerdown_delayed"
        If bMachineIsControllable Then
          tResponse = "Powering down after current record finishes."
          PowerDownAfterCurrentRecord()
        Else
          tResponse = "Machine cannot be controlled at this time."
        End If

      Case "/powerdown_now"
        If bMachineIsControllable Then
          tResponse = "Powering down immediately."
          PowerDownImmediately()
        Else
          tResponse = "Machine cannot be controlled at this time."
        End If

      Case "/test"
        tResponse = "OK"

      Case "/version"
        tResponse = clsUsbRelayDevice.LibVersion

      Case "/add_time"
        If bMachineIsControllable Then
          tResponse = "Enabling play timer and adding 10 minutes of play time."
          AddTime(10)
        Else
          tResponse = "Machine cannot be controlled at this time."
        End If

      Case "/get_minutes_remaining"
        tResponse = m_oPlayTimer.MinutesLeft

      Case "/get_current_audio_connections"
        tResponse = String.Join(vbCrLf, CurrentAudioConnections(CInt(txtAudioPort.Text)))

      Case "/drop_audio_connections_to"
        tResponse = ""

      Case "/get_current_audio_connection_count"
        tResponse = CurrentAudioConnections(CInt(txtAudioPort.Text)).Count

      Case Else
        tResponse = "Unsupported command."
    End Select
=end
end
