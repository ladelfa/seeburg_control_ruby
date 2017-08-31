#!/usr/local/bin/ruby

# STATE         LOCAL POWER?     REMOTE CONTROL?    PLAYING?
#
# off           Off              No                 No
# standby       On               Yes                No
# public_play   On               Yes                Yes
# home_play     On               No                 Yes
# maintenance   Unknown          No                 Unknown

PERMITTED_STATUSES = %w(off standby public_play home_play maintenance)

require "cgi"
cgi = CGI.new("html4")

remote_ip = cgi.remote_addr
jukebox_status = cgi["status"]
authorized = (cgi["jukebox"] == "seeburg")

if authorized
  if PERMITTED_STATUSES.include?(jukebox_status.downcase)
    response = "Set the jukebox Status to \"#{jukebox_status}\""
    File.open('tmp/jukebox_status.txt', 'w') {|f| f.write(jukebox_status) }
  else
    response = "Invalid status"
  end
else
  response = "Invalid authorization string."
end

cgi.out() {
  cgi.html{
    response
  }
}



