require 'sinatra'
require "sinatra/reloader" if development?
require 'tilt'

class SinatraProfileManager < Sinatra::Base

  configure do
    enable(:sessions)
  end

  get '/' do
    erb(:index)
  end

  get '/profile/:username' do
    erb(:profile)
  end

  get '/login' do
    erb(:login)
  end

  get '/register' do
    erb(:register)
  end

  not_found do
    erb(:not_found)
  end

end