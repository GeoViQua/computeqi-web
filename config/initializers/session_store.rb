# Be sure to restart your server when you modify this file.

ComputeQI::Application.config.session_store :cookie_store,
    key: '_computeqi_session',
    expire_after: 24.hours

Rails.application.config.middleware.insert_before(
  ActionDispatch::Session::CookieStore,
  FlashSessionCookieMiddleware,
  Rails.application.config.session_options[:key]
)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# ComputeQI::Application.config.session_store :active_record_store
