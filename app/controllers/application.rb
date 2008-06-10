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
 Mole.load_mole_configuration

  def rescue_action_in_public(exception)
    case exception.class.to_s
      when "ActionController::RoutingError"
        @this = "public/404.html" 
      else
        @this = "public/500.html"
    end
    render :file => @this
  end
  
  
  def local_request?
    false
  end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
 # protect_from_forgery  :secret => '7a5da40f867d91711ebc4f57706a884a'
end
