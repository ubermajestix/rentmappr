# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rentmappr_session',
  :secret      => 'f534fedd48f35b524607de13b465aae7de48a2903388f857bc5d8319a55c7076520e7be03c29f05c46ddb85aaedc6c884287a9af58bd26b62300ec2aaa69a08f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
