source "http://rubygems.org"
gemspec

group :test do
  gem 'pry',      require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'awesome_print'
  gem 'ruby_cowsay'
  gem 'rspec'
  gem 'ruby-prof'
  gem 'perftools.rb' #, git: 'git://github.com/tmm1/perftools.rb.git'
  # Pretty printed test output
  gem 'turn',      require: false
  gem 'simplecov', require: false
  gem 'factory_girl'
  gem 'forgery'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'guard-livereload'
  gem 'guard-coffeescript'
  gem 'guard-spork', github: 'guard/guard-spork'
  gem 'rack-perftools_profiler', require: 'rack/perftools_profiler'
  gem 'spork'
  gem 'fuubar'
  # gem 'webmock'
  if RUBY_PLATFORM =~ /darwin/
    gem 'rb-fsevent','~> 0.9.1'
  elsif RUBY_PLATFORM =~ /linux/
    gem 'rb-inotify'
  end
end
