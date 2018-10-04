require "crypto/bcrypt/password"

module Paasdar::Model
  # TODO: trackable, rememberable...
  macro paasdar(*configurations)
    {% for config in configurations %}
      {{config.id}}!
    {% end %}
  end

  macro database_authenticatable!
    include Crypto

    {% klass = @type %}

    validate :email, "is required", ->(resource : {{klass}}) do
      (email = resource.email) ? !email.empty? : false
    end

    validate :email, "already in use", ->(resource : {{klass}}) do
      !!resource.id || !{{klass}}.find_by(email: resource.email)
    end

    validate :password, "is too short", ->(resource : {{klass}}) do
      resource.password_changed? ? resource.valid_password_size? : true
    end

    validate :password, "does not match with confirmation", ->(resource : {{klass}}) do
      resource.password_changed? ? resource.password_match? : true
    end

    property password_confirmation : String?
    private getter new_password : String?

    def password=(password : String)
      @new_password = password
      @encrypted_password = Bcrypt::Password.create(password, cost: 10).to_s
    end

    def password
      (hash = encrypted_password) ? Bcrypt::Password.new(hash) : nil
    end

    def password_changed?
      new_password ? true : false
    end

    def password_match?
      new_password == password_confirmation
    end

    def valid_password_size?
      (pass = new_password) ? pass.size >= 8 : false
    end

    def authenticate(password : String)
      (bcrypt_pass = self.password) ? bcrypt_pass == password : false
    end
  end

  macro confirmable!
    before_create :make_confirmable!

    def confirmed?
      confirmed_at && !confirmation_token && !confirmation_sent_at
    end

    def confirm!
      self.confirmation_token = nil
      self.confirmation_sent_at = nil
      self.confirmed_at = Time.now.to_utc
      # TODO: Log bug...
      self.save
    end


    private def make_confirmable!
      self.confirmation_token = UUID.random.to_s
      self.confirmation_sent_at = Time.now.to_utc
    end
  end

  macro recoverable!
    def make_recoverable!
      self.reset_password_token = UUID.random.to_s
      self.reset_password_sent_at = Time.now.to_utc
      self.save
    end

    def reset_password!(params)
      self.password = params["password"].to_s
      self.password_confirmation = params["password_confirmation"]

      # Isolated this because if validation fail, the token is nil
      # on user instance and becomes an issue for the routes.
      if self.valid?
        self.reset_password_token = nil
        self.reset_password_sent_at = nil
        self.save
      end
    end
  end
end
