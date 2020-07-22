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

    def login_requirements_met?
      params.has_key?(@key_login_username) &&
      params.has_key?(@key_login_password)
    end

    def confirmation_requirements_met?
      selected_action = params[:action]
      %w(logout unregister).include?(selected_action)
    end

    def logout_requirements_met?
      choice = params[@key_confirm]
      !choice.nil? && %w(Yes No).include?(choice)
    end

    def unregister_requirements_met?
      logout_requirements_met?
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
    @key_confirm = ProfileManager::KEY_ERB_CONFIRM
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
    redirect('/register') unless login_requirements_met?

    username = params[@key_login_username]
    password = params[@key_login_password]

    if profile_manager.login_data_valid?(username, password)
      new_session_id = profile_manager.renew_login_session(username, cookie_session_id)

      if new_session_id
        set_session_success_message("You are now logged in as #{username}.")
        session[ProfileManager::KEY_SESSION_ID] = new_session_id
        redirect("profile/#{username}")
      else
        set_session_error_message("Login failed, please try again later :(")
        erb(:login)
      end
    else
      set_session_error_message("There is a problem with the username and/or password. Make sure you are registered!")
      erb(:login)
    end
  end

  post '/logout' do
    redirect('/') unless logout_requirements_met?

    choice = params[@key_confirm].downcase

    if choice == 'yes' && profile_manager.session_id_logged_in?(cookie_session_id)
        logout_successful = profile_manager.logout(cookie_session_id)

        if logout_successful
          set_session_success_message("You have been logged out.")
        end
    end

    redirect('/')
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
    redirect('/') unless unregister_requirements_met?

    choice = params[@key_confirm].downcase

    
    if choice == 'yes' && profile_manager.session_id_logged_in?(cookie_session_id)
      unregistering_successful = profile_manager.unregister(cookie_session_id)

      if unregistering_successful
        set_session_success_message("Your account has been fully deleted.")
      else
        set_session_error_message("There was a problem deleting your account. Please try again.")
      end
    end

    redirect('/')
  end

  get '/confirm/:action' do

    redirect('/') unless confirmation_requirements_met?

    action = params[:action]

    # define confirmation message and route based on
    # the chosen url action
    confirmation_message = nil
    confirmation_route = nil

    case action
    when 'logout'
      confirmation_message = 'Do you really want to log out?'
      confirmation_route = '/logout'
    when 'unregister'
      confirmation_message = 'Do you really want to unregister?'
      confirmation_route = '/unregister'
    end

    # return confirmation page
    @confirmation_message = confirmation_message
    @confirmation_route = confirmation_route
    erb(:confirm)
  end

  get '/debug' do
    headers['Content-Type'] = 'text/plain'
    profile_manager.connections_and_users_description_string
  end

  not_found do
    erb(:not_found)
  end

end