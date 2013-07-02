module TrivialSso
  class Login

    # signing and un-signing may have to be refactored to use OpenSSL:HMAC...
    # as this will not work well across platforms. (ideally this should work for PHP as well)

    # Decodes and verifies an encrypted cookie
    # throw a proper exception if a bad or invalid cookie.
    # otherwise, return the username and userdata stored in the cookie
    def self.decode_cookie(cookie = nil)
      begin
        raise TrivialSso::Error::MissingCookie if cookie.nil? || cookie.empty?
        userdata, timestamp = encrypted_message.decrypt_and_verify(cookie)
        raise TrivialSso::Error::LoginExpired if check_timestamp(timestamp)
        userdata
      rescue NoMethodError
        raise TrivialSso::Error::MissingConfig
      rescue ActiveSupport::MessageVerifier::InvalidSignature ||
             ActiveSupport::MessageEncryptor::InvalidMessage
        raise TrivialSso::Error::BadCookie
      end
    end

    # create an encrypted and signed cookie containing userdata and an expiry date.
    # userdata should be an array, and at minimum include a 'username' key.
    # using json serializer to hopefully allow future cross version compatibliity
    # (Marshall, the default serializer, is not compatble between versions)
    def self.cookie(userdata, expire_date = default_expire_date)
      begin
        raise TrivialSso::Error::MissingConfig    if sso_secret
        raise TrivialSso::Error::NoUsernameCookie if check_username(userdata)
        enc.encrypt_and_sign([userdata, expire_date])
      rescue NoMethodError
        raise TrivialSso::Error::MissingConfig
      end
    end

   private

    def self.check_username(userdata)
        userdata.nil?                 ||
        userdata.empty?               ||
      ! userdata.has_key?('username') ||
        userdata['username'].empty?
    end

    def self.enc
      ActiveSupport::MessageEncryptor.new(sso_secret , serializer: JSON)
    end

    def self.default_expire_date
      (9.hours.from_now).to_i
    end

    def self.check_timestamp(timestamp)
      (timestamp - DateTime.now.to_i) <= 0
    end

    def self.encrypted_message
      raise TrivialSso::Error::MissingRails unless defined? Rails
      ActiveSupport::MessageEncryptor.new(sso_secret, serializer: JSON)
    end

    def self.sso_secret
      check_for_rails
      if Rails.configuration.sso_secret.nil? || Rails.configuration.sso_secret.empty?
        raise TrivialSso::Error::MissingConfig
      end
      Rails.configuration.sso_secret
    end

    def self.check_for_rails
      raise TrivialSso::Error::MissingRails unless defined?(Rails)
    end

  end
end
