#!/usr/local/bin/ruby

require "cgi"
require "yaml"
require "rubygems"
require "json"

PERMITTED_ACTIONS = %w{ 
                        camera_ip camera_ports camera_urls test image
                      }
                      
CACHE_FILE_CAMERA_URL = '../tmp/camera_url.txt'
CAMERA_PORTS = %w( 8082 )

def main
  cgi = CGI.new("html4")

  remote_ip = cgi.remote_addr
  action = cgi.has_key?("action") ? cgi["action"].to_s : nil
  
  authorized = true
  
  status = "OK"
  
  if !authorized
    response = "Invalid authorization."
    status = "NOT_ACCEPTABLE"
  elsif !PERMITTED_ACTIONS.include?(action)
    response = "Invalid action."
    status = "BAD_REQUEST"
  else
    case action
      when "camera_ip"
        response = camera_ip
        
      when "camera_ports"
        response = camera_ports.to_json
        
      when "camera_urls"
        response = camera_urls.to_json
        
      when "test"
        response = "OK"
        
      when "image"
        response = "TODO" 
    end
  end
    
  cgi.out("expires" => Time.now, "status" => status) {
    response
  }
end

def camera_urls
  camera_ports.map{|p| "http://#{camera_ip}:#{p}/cam_1.jpg"}
end

def camera_ip
  r = ""
  File.open(CACHE_FILE_CAMERA_URL, 'r') {|f| r = f.read }
  r.gsub(/:\d*/, '') # Remove port, if specified
end

def camera_ports
  CAMERA_PORTS
end

main