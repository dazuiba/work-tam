# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tam_session',
  :secret      => '4b59eefbde618d184229f54faa1556e2c463b11d5a5fc9d56c5a5958ac60806ad4b75c017c347efd701d6c5598c41fa22f06bd0d15c341521d92d57aa0de4ee9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
