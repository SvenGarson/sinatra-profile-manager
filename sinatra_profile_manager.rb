require 'sinatra'
require "sinatra/reloader" if development?
require 'tilt'
require_relative 'lib/profile_manager'

Peep = 'Show'

class SinatraProfileManager < Sinatra::Base

  configure do
    # Configure Sinatra
    enable(:sessions)

    # Configure Application
    set(:profile_manager, ProfileManager::Application.new)
    set(:some_user, ProfileManager::User.new('Markus', 'QWERTZ'))
  end

  helpers do
    def profile_manager
      settings.profile_manager
    end

    def cookie_session_id
      session[ProfileManager::SESSION_ID_KEY]
    end

  end

  before do
    # ???
  end

  after do
    # ???
  end

  get '/' do
    if profile_manager.session_id_logged_in?(cookie_session_id)
      erb(:profile)
    else
      erb(:login)
    end
  end

  get '/profile/:username' do
    erb(:profile)

    # ??? check that routes that get here include the username in the URL
    if profile_manager.session_id_logged_in?(cookie_session_id)
      user_info = app.session_user_info(cookie_session_id)
      @username = user_info.username
      @registration_date = user_info.registration_date

      erb(:profile)
    else
      erb(:index)
    end
  end

  get '/login' do
    
    if profile_manager.session_id_logged_in?(cookie_session_id)
      erb(:profile)
    else
      # login procedure
      erb(:login)
    end
  end

  post '/login' do
    # check if all login parameters given
    login_username = params['field_username']
    login_password = params['field_password']
    if login_username.nil? || login_password.nil?
      redirect('/login')
    end

    if profile_manager.session_id_logged_in?(cookie_session_id)
      erb(:profile)
    else
      # login procedure
      
    end
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
    if app.session_id_logged_in?(cookie_session_id)
      erb(:profile)
    else
      erb(:register)
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
        erb(:index)
      else
        set_session_error_message(There was a problem deleting your account. Please login in and try again!)
        erb(:login)
    else
      erb(:profile)
    end
=end
  end

  post '/register' do
    erb(:register)
=begin
    username = ...
    hashed_password = ...
    original_password_length = ...

    if !username_valid?user(username)
      set_session_error_message(username_error(username))
      erb(:register)
    elsif !password_valid?(password)
      set_session_error_message(password_error?(original_password_length))
      @username_override = username
      erb(:register)
    else
      # username and password valid
      registration_successful = app.register_new_user(username, hashed_password) # set set registration time

      if registration_successful
        set_session_success_message('Account created yuhuuu ...')
        erb(:login)
      else
        set_session_error(app.lastest_error_string())
        erb(:register)
      end
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