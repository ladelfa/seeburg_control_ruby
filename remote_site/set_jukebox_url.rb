#!/usr/local/bin/ruby

require "cgi"
cgi = CGI.new("html4")

remote_ip = cgi.remote_addr
audio_port = cgi.has_key?("audio_port") ? cgi["audio_port"] : nil
control_port = cgi.has_key?("control_port") ? cgi["control_port"] : nil
video_port = cgi.has_key?("video_port") ? cgi["video_port"] : nil
stream_path = '/stream.mp3'

audio_url = [remote_ip, audio_port].compact.join(":") + stream_path
control_url = [remote_ip, control_port].compact.join(":")
video_url = [remote_ip, video_port].compact.join(":")

authorized = (cgi["jukebox"] == "seeburg")

if authorized
  response = "Set the jukebox URL to #{audio_url} and the control URL to #{control_url}."
  File.open('tmp/jukebox_url.txt', 'w') {|f| f.write(audio_url) }
  File.open('tmp/control_url.txt', 'w') {|f| f.write(control_url) }
  File.open('tmp/camera_url.txt', 'w') {|f| f.write(video_url) }
  #File.open('tmp/seeburg_remote.m3u', 'w') {|f| f.write("http://#{audio_url}") }
  #File.open('tmp/seeburg_remote.ram', 'w') {|f| f.write("http://#{audio_url}") }
  File.open('radio/.htaccess', 'w') {|f| f.write("RewriteEngine on\nRewriteRule ^.*$ http://#{audio_url} [R,L]\n") }
  #File.open('control/.htaccess', 'w') {|f| f.write("RewriteEngine on\nRewriteRule ^(.*)$ http://#{control_url}/$1 [L]\n") }
  
else
  response = "Invalid authorization string."
end

cgi.out() {
  cgi.html{
    response
  }
}



