require 'sinatra'
require "sinatra/reloader" if development?
require 'tilt'
require_relative 'lib/profile_manager'

class SinatraProfileManager < Sinatra::Base

  KEY_ERROR_MESSAGE = :ERROR_MESSAGE
  KEY_SUCCESS_MESSAGE = :SUCCESS_MESSAGE

  configure do
    # Configure Sinatra
    enable(:sessions)

    # Configure Application
    set(:profile_manager, ProfileManager::Application.new)
  end

  helpers do
    def profile_manager
      settings.profile_manager
    end

    def cookie_session_id
      session[ProfileManager::KEY_SESSION_ID]
    end

    def session_user_info
      profile_manager.session_user_info(cookie_session_id)
    end

    def profile_requirements_met?
      params.has_key?(:username)
    end

    def register_requirements_met?
      params.has_key?(@key_register_username) &&
      params.has_key?(@key_register_password)
    end

    def set_session_error_message(error_message)
      session[KEY_ERROR_MESSAGE] = error_message
    end

    def session_error_message_exist?
      session.has_key?(KEY_ERROR_MESSAGE)
    end

    def pop_session_error_message
      session.delete(KEY_ERROR_MESSAGE)
    end

    def set_session_success_message(success_message)
      session[KEY_SUCCESS_MESSAGE] = success_message
    end

    def session_success_message_exist?
      session.has_key?(KEY_SUCCESS_MESSAGE)
    end

    def pop_session_success_message
      session.delete(KEY_SUCCESS_MESSAGE)
    end
  end

  before do
    # define instance variables for use in ERB templates
    @key_login_username = ProfileManager::KEY_ERB_LOGIN_USERNAME
    @key_login_password = ProfileManager::KEY_ERB_LOGIN_PASSWORD
    @key_register_username = ProfileManager::KEY_ERB_REGISTER_USERNAME
    @key_register_password = ProfileManager::KEY_ERB_REGISTER_PASSWORD
  end

  get '/' do
    if profile_manager.session_id_logged_in?(cookie_session_id)
      username = session_user_info.username
      redirect("/profile/#{username}")
    else
      redirect('/login')
    end
  end

  get '/profile/:username' do
    redirect('/login') unless profile_requirements_met?

    if profile_manager.session_id_logged_in?(cookie_session_id)
      @user_info = session_user_info

      erb(:profile)
    else
      redirect('/login')
    end
  end

  get '/login' do
    
    if profile_manager.session_id_logged_in?(cookie_session_id)
      username = session_user_info.username

      redirect("/profile/#{username}")
    else
      erb(:login)
    end
  end

  post '/login' do
    erb(:login)
=begin
    session_id = session[:session_id]
    if app.session_id_logged_in?(session_id)
      erb(:profile)
    else
      username = ...
      hashed_password = ...
  
      if app.login_data_valid?(username, hashed_password)
        
        new_session_id = app.renew_login_validity(username, session_id)
        if new_session_id
          set_session_success_message('Login success. Valid until XYZ.')
          session[:SESSION_ID] = new_session_id
          erb(:profile)
        else
          set_session_error_message('Login failed ...')
          erb(:login)
        end
      else
        # login data invalid
        set_session_error_message("Login data invalid. Try again.")
        erb(:login)
      end
    end
=end
  end

  post '/logout' do
    erb(:profile)
=begin    
    session_id = session[:session_id]

    choice = params[:confirmation_choice]
    if choice == 'true'
      logout_success = app.logout(session_id)

      # When logout expires in this case before the action finished
      # it is not a problem because the end result is the same.
      set_session_success_message(You are now logged out!)
      erb(:login)
    else
      erb(:profile)
    end
=end
  end

  get '/register' do
    if profile_manager.session_id_logged_in?(cookie_session_id)
      username = session_user_info.username

      redirect("/profile/#{username}")
    else
      erb(:register)
    end
  end

  post '/register' do
    redirect('/register') unless register_requirements_met?

    username = params[@key_register_username]
    password = params[@key_register_password]

    if !profile_manager.username_valid?(username)
      set_session_error_message(profile_manager.latest_error_string)
      erb(:register)
    elsif !profile_manager.password_valid?(password)
      set_session_error_message(profile_manager.latest_error_string)
      erb(:register)
    else
      registration_successful = profile_manager.register_new_user(username, password)

      if registration_successful
        set_session_success_message("Account with username '#{username}' has been created.")
        redirect('/login')
      else
        set_session_error_message(profile_manager.latest_error_string)
        erb(:register)
      end
    end
  end

  post '/unregister' do
    erb(:profile)
=begin
    ??? What is user logged out at this point ???

    session_id = session[:session_id]

    choice = params[:confirmation_choice]
    if choice == 'true'
      unregister_success = app.unregister(session_id)

      if(unregister_success)      
        set_session_success_message(Your account has been deleted!)
        redirect('/')
      else
        set_session_error_message(There was a problem deleting your account. Please login in and try again!)
        erb(:login)
    else
      erb(:profile)
    end
=end
  end

  get '/confirm/:action' do
=begin

    # redirect if action not supported or none defined
    action = params[:action]
    if !['logout', 'unregister', nil].include?
      set_session_error_message('Action #action undefined.')
      redirect('/')
    end

    # define message to confirm based on action and
    # define where the confirmation is routed to
    confirmation_message = nil
    confirmation_route = nil

    case action
    when logout
      confirmation_message = 'You sure to ...'
      confirmation_route = '/logout'
    when unregister
      confirmation_message = 'You sure to ...'
      confirmation_route = '/unregister'
    end

    # make variables visible to template
    @confirmation_message = confirmation_message
    @confirmation_route = confirmation_route

    # confirmation sets parameters confirmation_choice

    erb(:confirm)
  
=end
    erb(:confirm)
  end

  not_found do
    erb(:not_found)
=begin
  
=end
  end

end