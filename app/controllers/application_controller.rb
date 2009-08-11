class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include GeoKit
  include Georb
  include GeoKit::Geocoders
  include AuthenticatedSystem
  include HoptoadNotifier::Catcher
  include Stats
  require 'open-uri'  

  def midnight
    Time.now - Time.now.sec - Time.now.min.minutes - Time.now.hour.hours
  end
  
  # def rescue_action_in_public(exception)
  #   case exception.class.to_s
  #     when "ActionController::RoutingError"
  #       @this = "public/404.html" 
  #     else
  #       @this = "public/500.html"
  #   end
  #   render :file => @this
  # end
    
  def local_request?
    false
  end
  
  def setup_session
    session[:saved_houses]  ||=[]
    session[:trashed_houses]||=[]
    session[:clicked_houses]||=[]
    session[:saved_houses].uniq!
    session[:trashed_houses].uniq!
    session[:clicked_houses].uniq!
    puts "ss"*25
    puts "saved " + session[:saved_houses].inspect  
    puts "trashed " + session[:trashed_houses].inspect
    puts "clicked " + session[:clicked_houses].inspect
    puts "ss"*25
  end
end
