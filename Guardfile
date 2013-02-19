# A sample Guardfile
# More info at https://github.com/guard/guard#readme
notification :tmux,
  :display_message => true,
  :timeout => 5, # in seconds
  :default_message_format => '%s >> %s',
  # the first %s will show the title, the second the message
  # Alternately you can also configure *success_message_format*,
  # *pending_message_format*, *failed_message_format*
  :line_separator => ' > ', # since we are single line we need a separator
  :color_location => 'status-left-bg' # to customize which tmux element will change color

group :frontend do
  guard :bundler do
    watch('Gemfile')
  end
end

guard :test do
  # watch(%r{^lib/(.+)\.rb$})           { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^lib/(.+)\.rb$})             { |m| "test/trivialsso_test.rb" }
  watch(%r{^test/.+_test\.rb$})

  # Rails example
  watch(%r{^app/models/(.+)\.rb$})      { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^app/controllers/(.+)\.rb$}) { |m| "test/functional/#{m[1]}_test.rb" }
  watch(%r{^app/views/.+\.rb$})         { "test/integration" }
  watch('app/controllers/application_controller.rb') {
    ["test/functional", "test/integration"] }
end
