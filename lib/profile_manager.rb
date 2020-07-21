module ProfileManager

  # constants to orchestrate data exchange between client and server
  KEY_ERB_LOGIN_USERNAME = 'field_login_username'
  KEY_ERB_LOGIN_PASSWORD = 'field_login_password'
  KEY_ERB_REGISTER_PASSWORD = 'field_register_password'
  KEY_ERB_REGISTER_USERNAME = 'field_register_username'
  KEY_SESSION_ID = :SESSION_ID

  # timing
  TIME_EXPIRED = Time.at(0)

  class User
    def initialize(p_username, p_password)
      self.username = p_username
      self.password = p_password
      self.registration_time = Time.now
      self.login_invalidation_time = TIME_EXPIRED
    end

    def username
      @username.dup
    end

    def password
      @password.dup
    end

    def registration_time
      @registration_time.dup
    end

    def login_valid?
      login_invalidation_time >= Time.now
    end

    def info
      UserInfo.new(self)
    end

    private def username=(new_username)
      @username = new_username.dup
    end

    private def password=(new_password)
      @password = new_password.dup
    end

    private def registration_time=(new_registration_time)
      @registration_time = new_registration_time.dup
    end

    private def login_invalidation_time
      @login_invalidation_time.dup
    end

    private def login_invalidation_time=(new_login_invalidation_time)
      @login_invalidation_time = new_login_invalidation_time.dup
    end
  end

  class UserInfo
    attr_reader(:username, :registration_date)

    def initialize(user)
      @username = user.username
      @registration_date = user.registration_time.strftime("%d of %B %Y")
    end
  end

  class Application
    USERNAME_MIN_LENGTH = 8
    USERNAME_MATCH_PATTERN = /\A[a-z]+[a-z\d]+\Z/i
    PASSWORD_MIN_LENGTH = 8

    def initialize
      @users = Hash.new
      @current_connections = Hash.new
    end

    def session_id_logged_in?(session_id)
      if current_connections.has_key?(session_id)
        user = current_connections[session_id]

        return true if user.login_valid?
      end

      false
    end

    def session_user_info(session_id)
      user = current_connections[session_id]
      user.info
    end

    private def username_exists?(new_username)
      users.any?{ |username, _| username == new_username }
    end

    def username_valid?(new_username)
      success = true

      if username_exists?(new_username)
        self.latest_error_string=("Username '#{new_username}' already exists.")
        success = false

      elsif new_username.length < USERNAME_MIN_LENGTH
        self.latest_error_string=("Username must be at least '#{USERNAME_MIN_LENGTH}' characters long.")
        success = false

      elsif !new_username.match?(USERNAME_MATCH_PATTERN)
        self.latest_error_string=("Username must begin with an alphabetical character. The rest can by any alpha-numerical character.")
        success = false
      end

      success
    end

    def password_valid?(password)
      success = true

      if password.length < PASSWORD_MIN_LENGTH
        self.latest_error_string=("Password must be at least '#{PASSWORD_MIN_LENGTH}' characters long.")
        success = false
      end

      success
    end

    def latest_error_string
      @error_string.dup
    end

    def register_new_user(username, password)
      success = true

      # check again whether the username already exists
      # just before actually creating the account
      if username_exists?(username)
        self.latest_error_string=("The username '#{username}' has just been taken :(")
        success = false
      else
        users[username] = User.new(username, password)
      end

      success
    end

    private def latest_error_string=(new_error_string)
      @error_string = new_error_string.dup
    end

    private def users
      @users
    end

    private def current_connections
      @current_connections
    end
  end

end