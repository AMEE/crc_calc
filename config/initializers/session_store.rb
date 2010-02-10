# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_crc_session',
  :secret      => '4e42c6e6dbc5d7ffe6fb45b1d1913de520d3e6004aa4572567f594c100fdf423e3fe90ee6256515c7990016adf3df9adfc9ccd93d8b7d197df3a46264809a18a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
