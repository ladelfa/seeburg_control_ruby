Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/test', to: 'application#test'
  get '/version', to: 'application#version'
  get '/powerup', to: 'jukebox#powerup'
  get '/powerdown_delayed', to: 'jukebox#powerdown_delayed'
  get '/powerdown_now', to: 'jukebox#powerdown_now'
  get '/reject', to: 'jukebox#reject'
end
