require 'net/http'

module PublicServer
  SEND_STATUS_CHANGES = Settings.public_server.send_status_changes
  STATUS_CGI_SETTINGS = Settings.public_server.status_cgi

  UPDATE_JUKEBOX_URL_ON_LAUNCH = Settings.public_server.update_jukebox_url_on_launch
  JUKEBOX_URL_CGI_SETTINGS = Settings.public_server.jukebox_url_cgi_settings

  def self.update_status(s)
    if SEND_STATUS_CHANGES
      uri = URI(STATUS_CGI_SETTINGS.url)
      uri.query = URI.encode_www_form(STATUS_CGI_SETTINGS.additional_params.to_h.merge(STATUS_CGI_SETTINGS.status_param => s))
      puts uri
      res = Net::HTTP.get_response(uri)
      puts res.body if res.is_a?(Net::HTTPSuccess)
    end
  end

  def self.update_jukebox_url
    audio_port    = JUKEBOX_URL_CGI_SETTINGS.audio_port     || AudioStream::AUDIO_STREAM_PORT
    control_port  = JUKEBOX_URL_CGI_SETTINGS.control_port # || Appication port
    stream_path   = JUKEBOX_URL_CGI_SETTINGS.stream_path    || AudioStream::AUDIO_STREAM_PATH

    uri = URI(JUKEBOX_URL_CGI_SETTINGS.url)
    params = JUKEBOX_URL_CGI_SETTINGS.additional_params.to_h

    params.merge!(audio_port: audio_port, control_port: control_port, stream_path: stream_path) # TODO also video_port

    uri.query = URI.encode_www_form(params)
    #puts uri
    res = Net::HTTP.get_response(uri)
    #puts res.body if res.is_a?(Net::HTTPSuccess)
  end

  def self.on_launch
    update_jukebox_url if UPDATE_JUKEBOX_URL_ON_LAUNCH
  end
end