#!/usr/local/bin/ruby

require "yaml"
require 'date'
require "cgi"
cgi = CGI.new("html4")

ACTION_LOG_FILE = '../tmp/control.log'
DAYS_TO_KEEP = 7

def log_array
  log_array = []
  load_now = Time.now

  File.foreach(ACTION_LOG_FILE) do |s|

    a = s.split(',')
    if a.length == 5
      request_at = Time.at(a[1].to_i)
      
      if (load_now - request_at) < (3600 * 24 * DAYS_TO_KEEP)
        log_array << {
          :session => a[0], 
          :request_at => request_at, 
          :ip => a[2], 
          :action => a[3], 
          :response => a[4]
        }
      end
    end

  end

  log_array
end 

def save_log_array!(logs)
  log_message = logs.map do |log|
    [ log[:session],
      log[:request_at].to_i, 
      log[:ip], 
      log[:action],
      log[:response]
    ].join(",")
  end.join("\n")
  File.open(ACTION_LOG_FILE, 'w') {|f| f.write(log_message) }
end

def local_time(t)
  lt = DateTime.parse(t.to_s).new_offset( Rational(-7,24) ).strftime("%F %a %r")
  age = Time.now - t
  lt = "<span class=\"recent\">#{lt}</span>" if age <= 7200
  lt = "<span class=\"today\">#{lt}</span>" if age > 7200 && age < (3600 * 24)
  lt
end

# Expected format:
#
#  log_hash = {  :session => session, 
#                :request_at => Time.now, 
#                :ip => remote_ip, 
#                :action => action, 
#                :response => response }

logs = log_array || []

# Filter out logs that are too old to care about
logs.reject!{|h| (Time.now - h[:request_at]) > (3600 * 24 * DAYS_TO_KEEP)}

save_log_array!(logs)

ips = logs.group_by{|h| h[:ip]}

response = "<h1>Control Logs as of #{local_time(Time.now)} (and #{DAYS_TO_KEEP} days previous)</h1>" + ips.map do |ip|
  sessions = ip[1].group_by{|h| h[:session]}
  url = "http://www.iplocation.net/index.php?query=#{ip[0]}"
  
  "<h2><a href=\"#{url}\">#{ip[0]}</a></h2>\n<dl>" + 
  sessions.map do |s| 
    session_label = s[0]
    requests = s[1]
    request_ats = requests.map{|r| r[:request_at]}
    session_first_req_at = request_ats.min
    session_last_req_at = request_ats.max

    "<dt>#{session_label}</a>\n" + 
    "<dd>First: #{local_time(session_first_req_at)}</dd>" + 
    requests.map do |r|    
      if %w(get_current_status get_minutes_remaining get_current_audio_connection_count).include? r[:action]
        nil #ignore these.
      else
        "<dd>#{local_time(r[:request_at])}: #{r[:action]} => #{r[:response]}</dd>"
      end
    end.compact.join("\n") + 
    "<dd>Last: #{local_time(session_last_req_at)} (#{requests.length} requests)</dd>\n</dt>"
  end.compact.join() + 
  "</dl>"
end.join()

cgi.out("expires" => Time.now) {
  cgi.html {
    cgi.head {
      "<STYLE>.recent{color:#F00; font-weight:bold;} .today{color:#A00}</STYLE>"
    } +
    cgi.body {
      response
    }
  }
}
