module ProfileManager

  SESSION_ID_KEY = :SESSION_ID
  TIME_EXPIRED = Time.at(0)

  class User
    def initialize(p_username, p_hashed_password)
      self.username = p_username
      self.hashed_password = p_hashed_password
      self.registration_time = Time.now
      self.login_invalidation_time = Time.now + 5
    end

    def username
      @username.dup
    end

    def hashed_password
      @hashed_password.dup
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

    private def hashed_password=(new_hashed_password)
      @hashed_password = new_hashed_password.dup
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

    private def users
      @users
    end

    private def current_connections
      @current_connections
    end
  end

end