require 'tray-checkout'
require 'webmock/rspec'
require 'vcr'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.order = "random"
end

Tray::Checkout.configure do |config|
  config.log_enabled = false
end
