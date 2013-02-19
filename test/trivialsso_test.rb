require 'active_support/core_ext'
require 'rails/all'
require 'test/unit'

# Need the mocha gem to properly stub out rails configuration.
require 'mocha/setup'
require 'trivialsso'
require 'forgery'
require 'securerandom'

##
# Test suite for Trivialsso. Which requires rails (for config values) and active_support for time calculations.
#
class TrivialssoTest < Test::Unit::TestCase

  def setup
    # Stub out our Rails config so we can test things properly.
    Rails.stubs(:configuration).returns(Rails::Application::Configuration.allocate)
    Rails.configuration.sso_secret = SecureRandom.hex(64)
    @user_name      = Forgery::Internet.user_name
    @data           = Forgery::LoremIpsum.words(20)
    @userdata       = {'username' => @user_name, 'data' => @data}
    @expired_cookie = Trivialsso::Login.cookie({'username' => 'testor'}, 2.seconds.ago)
  end

  def test_create_cookie_with_userdata
    assert_not_nil Trivialsso::Login.cookie(@userdata)
  end

  def test_create_cookie_and_decode_it
    mycookie = Trivialsso::Login.cookie(@userdata)
    data     = Trivialsso::Login.decode_cookie(mycookie)
    assert_equal data['data'],  @data
  end

  def test_throw_exception_on_missing_username
    assert_raise Trivialsso::Error::NoUsernameCookie do
      mycookie = Trivialsso::Login.cookie("")
    end
  end

  def test_expire_date_exists
    # in a full rails environment, this will return an ActiveSupport::TimeWithZone
    assert Trivialsso::Login.expire_date.is_a?(Time),
      "proper Time object not returned"
  end

  def test_expire_date_is_in_future
    assert (DateTime.now < Trivialsso::Login.expire_date),
      "Expire date is in the past - cookie will expire immediatly."
  end

  def test_raise_exception_on_blank_cookie
    assert_raise Trivialsso::Error::MissingCookie do
      Trivialsso::Login.decode_cookie("")
    end
  end

  def test_raise_exception_on_bad_cookie
    assert_raise Trivialsso::Error::BadCookie do
      Trivialsso::Login.decode_cookie("BAhbB0kiC2RqbGVlMgY6BkVUbCsHo17iTg")
    end
  end

  def test_raise_exception_on_expired_cookie
    assert_raise Trivialsso::Error::LoginExpired do
      Trivialsso::Login.decode_cookie(@expired_cookie)
    end
  end

end
