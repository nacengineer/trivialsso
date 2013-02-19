# This file is required to define the shared secret used for generating and decoding
# SSO cookies. This secret *must* be the same across all of your applications.
require 'securerandom'

<%= Rails.application.class.parent_name %>::Application.config.sso_secret = SecureRandom.hex(64)
