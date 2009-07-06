class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include GeoKit
  include Georb
  include GeoKit::Geocoders
  include AuthenticatedSystem
  require 'open-uri'  

  def midnight
    Time.now - Time.now.sec - Time.now.min.minutes - Time.now.hour.hours
  end
  
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

end
