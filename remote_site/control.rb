#!/usr/local/bin/ruby

require "cgi"
require "yaml"

PERMITTED_ACTIONS = %w{ 
                        reject test version add_time 
                        powerup powerdown_now powerdown_delayed 
                        get_minutes_remaining get_current_status get_blacklist 
                        get_current_audio_connections get_current_audio_connection_count
                        drop_audio_connections_to
                      }
                      
CACHE_FILE_MINUTES = 'tmp/minutes_remaining.txt'
CACHE_FILE_AUDIO_CONN_COUNT = 'tmp/current_audio_connection_count.txt'
CACHE_FILE_STATUS = 'tmp/jukebox_status.txt'
CACHE_FILE_CONTROL_URL = 'tmp/control_url.txt'
ACTION_LOG_FILE = 'tmp/control.log'
CACHE_FILE_JUKEBOX_URL = 'tmp/jukebox_url.txt'
BLACKLIST_IP_FILE = 'tmp/blacklist.txt'

def main
  cgi = CGI.new("html4")

  remote_ip = cgi.remote_addr
  action = cgi.has_key?("action") ? cgi["action"].to_s : nil
  session = cgi.has_key?("session") ? cgi["session"].to_s : nil

  authorized = true
  blacklisted = get_blacklist.include?(remote_ip)
  
  status = "OK"
  
  if !authorized || !session
    response = "Invalid authorization."
    status = "NOT_ACCEPTABLE"
  elsif !PERMITTED_ACTIONS.include?(action)
    response = "Invalid action."
    status = "BAD_REQUEST"
  else
    case action
      when "get_blacklist"
        response = get_blacklist.join("<br/>\n")
        
      when "get_current_status"
        response = get_current_status
        
      when "get_minutes_remaining"
        response = get_minutes_remaining.to_s      

      when "get_current_audio_connection_count"
        response = get_current_audio_connection_count.to_s      
      
      
      when "add_time"
        if blacklisted
          response = "Blacklisted."
          status = "FORBIDDEN"
        else
          clear_minutes_remaining_cache
          response = get_action_response_from_jukebox("add_time")
        end
      
      when "drop_audio_connections_to"
        ip_address = cgi.has_key?("ip") ? cgi["ip"].to_s : nil
        if ip_address
          response = drop_audio_connections_to(ip_address)
        else
          response = "Unspecified IP Address"
          status = "BAD_REQUEST"
        end
      else
        if blacklisted
          response = "Blacklisted."
          status = "FORBIDDEN"
        else
          response = get_action_response_from_jukebox(action)
        end
    end
  end
  
  unless remote_ip == jukebox_ip  # Don't log requests from the jukebox owner's IP; there are likely to be many. 
    log_array = [ session.to_s, 
                  Time.now.to_i, 
                  remote_ip.to_s, 
                  action.to_s, 
                  response.to_s ]

    log_message = "#{log_array.join(',')}\n"

    File.open(ACTION_LOG_FILE, 'a') {|f| f.write(log_message) }
  end
  
  cgi.out("expires" => Time.now, "status" => status) {
    response
  }
end

def control_url
  r = ""
  File.open(CACHE_FILE_CONTROL_URL, 'r') {|f| r = f.read }
  r
end

def jukebox_ip
  r = ""
  File.open(CACHE_FILE_JUKEBOX_URL, 'r') {|f| r = f.read }
  r.gsub(/:\d*/, '') # Remove port, if specified
end

def get_action_response_from_jukebox(a)
  response = `curl http://#{control_url}/#{a}`
  if response == ''
    show_bad_response
  end
  response
end

def show_bad_response
  test_response = `curl http://#{control_url}/test`
  if test_response == ''
    begin
      File.open(CACHE_FILE_STATUS, 'w') {|f| r = f.write("maintenance")}
    rescue
    end
  end
end

def get_current_status
  # This one we can answer without going back to the juke itself.
  r = "unknown"
  begin
    File.open(CACHE_FILE_STATUS, 'r') {|f| r = f.read.downcase }
  rescue
  end
  r
end

def get_blacklist
  blist = []
  begin
    # This one we can answer without going back to the juke itself.
    File.foreach(BLACKLIST_IP_FILE) do |s|
      blist << s.strip
    end
  rescue
  end
  blist.compact
end


def get_minutes_remaining
  mins = 0
   
  # Is the local cache file older than a minute? 
  if File.file?(CACHE_FILE_MINUTES) && (Time.now - File.mtime(CACHE_FILE_MINUTES)) < 60
    # Use its contents
    File.open(CACHE_FILE_MINUTES, 'r') {|f| mins = f.read.to_i}
  else
    # Go get the number from the juke
    mins = get_action_response_from_jukebox("get_minutes_remaining").to_i
    # Update the cache file
    File.open(CACHE_FILE_MINUTES, 'w') {|f| f.write(mins)}
  end

  mins
end

def get_current_audio_connection_count
  connections = 0
   
  # Is the local cache file older than a minute? 
  if File.file?(CACHE_FILE_AUDIO_CONN_COUNT) && (Time.now - File.mtime(CACHE_FILE_AUDIO_CONN_COUNT)) < 60
    # Use its contents
    File.open(CACHE_FILE_AUDIO_CONN_COUNT, 'r') {|f| connections = f.read.to_i}
  else
    # Go get the number from the juke
    connections = get_action_response_from_jukebox("get_current_audio_connection_count").to_i
    # Update the cache file
    File.open(CACHE_FILE_AUDIO_CONN_COUNT, 'w') {|f| f.write(connections)}
  end

  connections
end

def drop_audio_connections_to(ip_address)
  get_action_response_from_jukebox("drop_audio_connections_to?ip=#{ip_address}")
end

def clear_minutes_remaining_cache
  begin
    File.delete(CACHE_FILE_MINUTES)
  rescue
  end
end
main