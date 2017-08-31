#!/usr/local/bin/ruby

# STATE         LOCAL POWER?     REMOTE CONTROL?    PLAYING?
#
# off           Off              No                 No
# standby       On               Yes                No
# public_play   On               Yes                Yes
# home_play     On               No                 Yes
# maintenance   Unknown          No                 Unknown

require "cgi"
cgi = CGI.new("html4")

FORMATS = %w(code text html)
if (f = cgi["format"]) && FORMATS.include?(f.downcase)
  format = f.downcase.to_sym    
else
  format = :html
end

jukebox_status = "unknown"
begin
  File.open('tmp/jukebox_status.txt', 'r') {|f| jukebox_status = f.read }
rescue
end

if format == :code
  response = jukebox_status.downcase
else
  case jukebox_status.downcase
    when "off"
      response = "The jukebox is currently turned off."
    when "standby"
      response = "The jukebox is currently in standby mode, and can be turned on remotely."
    when "public_play"
      response = "The jukebox is currently on, and can be controlled remotely."
    when "home_play"
      response = "The jukebox is currently on, but remote control is disabled at this time."
    when "maintenance"
      response = "The jukebox is currently offline for maintenance."
    else
      response = "The jukebox is currently in an unknown state."
  end
end

cgi.out("expires" => Time.now) {
  if format == :html
    cgi.html{
      response
    }
  else
    response
  end
}



