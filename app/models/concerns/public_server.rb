require 'net/http'

class PublicServer
  SEND_STATUS_CHANGES = Settings.public_server.send_status_changes
  STATUS_CGI_SETTINGS = Settings.public_server.status_cgi

  def update_status(s)
    if SEND_STATUS_CHANGES
      uri = URI(STATUS_CGI_SETTINGS.url)
      uri.query = URI.encode_www_form(STATUS_CGI_SETTINGS.additional_params.to_h.merge(STATUS_CGI_SETTINGS.status_param => s))
      puts uri
      res = Net::HTTP.get_response(uri)
      puts res.body if res.is_a?(Net::HTTPSuccess)
    end
  end
end