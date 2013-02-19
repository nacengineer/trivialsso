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
        raise Trivialsso::Error::MissingConfig if Rails.configuration.sso_secret.blank?
      rescue NoMethodError
        raise Trivialsso::Error::MissingConfig
      end
      raise Trivialsso::Error::NoUsernameCookie if userdata['username'].blank?
      enc = ActiveSupport::MessageEncryptor.new(Rails.configuration.sso_secret, :serializer => JSON)
      cookie = enc.encrypt_and_sign([userdata,exp_date.to_i])
      return cookie
    end

    # Decodes and verifies an encrypted cookie
    # throw a proper exception if a bad or invalid cookie.
    # otherwise, return the username and userdata stored in the cookie
    def self.decode_cookie(cookie)
      begin
        raise Trivialsso::Error::MissingConfig if Rails.configuration.sso_secret.blank?
      rescue NoMethodError
        raise Trivialsso::Error::MissingConfig
      end
      if cookie.blank?
        raise Trivialsso::Error::MissingCookie
      else
        enc = ActiveSupport::MessageEncryptor.new(Rails.configuration.sso_secret, :serializer => JSON)
        begin
          userdata, timestamp = enc.decrypt_and_verify(cookie)
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          #raise our own cookie error instead of passing on invalid signature.
          raise Trivialsso::Error::BadCookie
        rescue ActiveSupport::MessageEncryptor::InvalidMessage
          #raise our own cookie error instead of passing on invalid message.
          raise Trivialsso::Error::BadCookie
        end

        # Determine how many seconds our cookie is valid for.
        timeRemain = timestamp - DateTime.now.to_i

        #make sure current time is not past timestamp.
        if timeRemain > 0
          userdata
        else
          raise Trivialsso::Error::LoginExpired
        end
      end
    end

    #returns the exipiry date from now. Used for setting an expiry date when creating cookies.
    def self.expire_date
      9.hours.from_now
    end

  end
end
