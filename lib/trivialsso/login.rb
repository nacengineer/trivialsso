module Trivialsso
  class Login

    # signing and un-signing may have to be refactored to use OpenSSL:HMAC...
    # as this will not work well across platforms. (ideally this should work for PHP as well)

    # create an encrypted and signed cookie containing userdata and an expiry date.
    # userdata should be an array, and at minimum include a 'username' key.
    # using json serializer to hopefully allow future cross version compatibliity
    # (Marshall, the default serializer, is not compatble between versions)
    def self.cookie(userdata, exp_date = expire_date)
      begin
        raise Trivialsso::Error::MissingConfig    if Rails.configuration.sso_secret.blank?
        raise Trivialsso::Error::NoUsernameCookie if userdata['username'].blank?
        enc = ActiveSupport::MessageEncryptor.new(Rails.configuration.sso_secret,
                                                  :serializer => JSON)
        enc.encrypt_and_sign([userdata,exp_date.to_i])
      rescue NoMethodError
        raise Trivialsso::Error::MissingConfig
      end
    end

    # Decodes and verifies an encrypted cookie
    # throw a proper exception if a bad or invalid cookie.
    # otherwise, return the username and userdata stored in the cookie
    def self.decode_cookie(cookie)
      begin
        raise Trivialsso::Error::MissingCookie if cookie.blank?
        userdata, timestamp = encrypted_message.decrypt_and_verify(cookie)
        raise Trivialsso::Error::LoginExpired unless (timestamp - DateTime.now.to_i) > 0
        userdata
      rescue NoMethodError
        raise Trivialsso::Error::MissingConfig
      rescue ActiveSupport::MessageVerifier::InvalidSignature ||
             ActiveSupport::MessageEncryptor::InvalidMessage
        raise Trivialsso::Error::BadCookie
      end
    end

    #returns the exipiry date from now. Used for setting an expiry date when creating cookies.
    def self.expire_date
      9.hours.from_now
    end

    def self.encrypted_message
      sso_secret = Rails.configuration.sso_secret
      raise Trivialsso::Error::MissingConfig if sso_secret.blank?
      ActiveSupport::MessageEncryptor.new(sso_secret, serializer: JSON)
    end

  end
end
