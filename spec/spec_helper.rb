require 'rubygems'
require 'spork'
# uncomment the following line to use spork with the debugger
# require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'

  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start
  end

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/autorun'
  require 'rspec/mocks'
  require 'factory_girl'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.include Rails.application.routes.url_helpers
    config.mock_with :rspec

    config.use_transactional_fixtures = false
    config.infer_base_class_for_anonymous_controllers = false
    config.order = "random"

    config.before(:all) do
      DeferredGarbageCollection.start
    end

    config.after(:all) do
      DeferredGarbageCollection.reconsider
    end

    config.before :suite do
      PerfTools::CpuProfiler.start("#{profile_directory}/rspec_profile")
    end

    config.after :suite do
      PerfTools::CpuProfiler.stop
    end

    def profile_directory
      directory = "/tmp/trivial-sso"
      system("mkdir #{directory}") unless Dir.exist? directory
      directory
    end

  end
end

Spork.each_run do
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start
  end
  FactoryGirl.reload
  RSpec.configure do |config|
    def svg_filename
      "/tmp/trivial-sso/profile-#{Time.now.localtime.strftime("%H%M%S")}.svg"
    end
  end
end
