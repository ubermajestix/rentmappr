# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
include GeoKit
include GeoKit::Geocoders
  include AuthenticatedSystem
  require 'open-uri'
  require 'hpricot'
  include Georb


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '7a5da40f867d91711ebc4f57706a884a'
end
