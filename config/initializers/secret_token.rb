require 'securerandom'

if Rails.env.production? && ENV['SECRET_TOKEN'].blank?
  raise 'SECRET_TOKEN env variable must be set!'
end

# SecureRandom used as fallback only since session cookies will be regenerated
ComputeQI::Application.config.secret_token = ENV['SECRET_TOKEN'] || SecureRandom.hex(64)