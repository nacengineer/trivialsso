require 'active_support/core_ext'
require 'spec/**/'

# Need the mocha gem to properly stub out rails configuration.
require 'trivial_sso'
require 'forgery'
require 'securerandom'

describe TrivialSso do

  def before
    # Stub out our Rails config so we can test things properly.
    Rails.stubs(:configuration).returns(Rails::Application::Configuration.allocate)
    Rails.configuration.sso_secret = SecureRandom.hex(64)
    @user_name      = Forgery::Internet.user_name
    @data           = Forgery::LoremIpsum.words(20)
    @userdata       = {'username' => @user_name, 'data' => @data}
    @expired_cookie = TrivialSso::Login.cookie(
      {'username' => 'testor'}, 2.seconds.ago
    )
  end

  it "does create cookie with userdata" do
    TrivialSso::Login.cookie(@userdata).should_not be_nil
  end

  # def test_create_cookie_and_decode_it
  #   mycookie = TrivialSso::Login.cookie(@userdata)
  #   data     = TrivialSso::Login.decode_cookie(mycookie)
  #   assert_equal data['data'],  @data
  # end

  # def test_throw_exception_on_missing_username
  #   assert_raise TrivialSso::Error::NoUsernameCookie do
  #     mycookie = TrivialSso::Login.cookie("")
  #   end
  # end

  # def test_expire_date_exists
  #   # in a full rails environment, this will return an ActiveSupport::TimeWithZone
  #   assert TrivialSso::Login.expire_date.is_a?(Time),
  #     "proper Time object not returned"
  # end

  # def test_expire_date_is_in_future
  #   assert (DateTime.now < TrivialSso::Login.expire_date),
  #     "Expire date is in the past - cookie will expire immediatly."
  # end

  # def test_raise_exception_on_blank_cookie
  #   assert_raise TrivialSso::Error::MissingCookie do
  #     TrivialSso::Login.decode_cookie("")
  #   end
  # end

  # def test_raise_exception_on_bad_cookie
  #   assert_raise TrivialSso::Error::BadCookie do
  #     TrivialSso::Login.decode_cookie("BAhbB0kiC2RqbGVlMgY6BkVUbCsHo17iTg")
  #   end
  # end

  # def test_raise_exception_on_expired_cookie
  #   assert_raise TrivialSso::Error::LoginExpired do
  #     TrivialSso::Login.decode_cookie(@expired_cookie)
  #   end
  # end

end
