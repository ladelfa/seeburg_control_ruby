Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/test', to: 'application#test'
  get '/version', to: 'application#version'
  get '/get_current_audio_connections', to: 'application#get_current_audio_connections'
  get '/get_current_audio_connection_count', to: 'application#get_current_audio_connection_count'
  get '/restart_audio_stream', to: 'application#restart_audio_stream'
  get '/start_radio_transmitter', to: 'application#start_radio_transmitter'
  get '/stop_radio_transmitter', to: 'application#stop_radio_transmitter'
  get '/require_audio_connection', to: 'application#require_audio_connection'
  get '/dont_require_audio_connection', to: 'application#dont_require_audio_connection'

  get '/powerup', to: 'jukebox#powerup'
  get '/powerdown_delayed', to: 'jukebox#powerdown_delayed'
  get '/powerdown_now', to: 'jukebox#powerdown_now'
  get '/reject', to: 'jukebox#reject'
  get '/add_time', to: 'jukebox#add_time'
  get '/clear_time', to: 'jukebox#clear_time'
  get '/get_minutes_remaining', to: 'jukebox#get_minutes_remaining'
  get '/get_seconds_remaining', to: 'jukebox#get_seconds_remaining'
  get '/set_status', to: 'jukebox#set_status'

  get '/admin', to: 'admin#index'
  get '/admin/current_stats', to: 'admin#current_stats'
  get '/admin/history', to: 'admin#history'

  root to: redirect('/admin')
end
