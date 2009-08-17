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
# class Gaslamp
#   attr_accessor :conds
#   
#   def add_query(conds)
#     @conds << format_query(conds)
#   end
#   
  def format_query(db_query, bind_variables)
    # if there is a like and bindvar is a string wrap it in % ???
    if bind_variables.kind_of?(String) or bind_variables.kind_of?(Fixnum)
      bind_varialbles = bind_variables.to_s if bind_variables.kind_of?(Fixnum)
      if bind_variables and not bind_variables.blank?
        bind_variables = "%#{bind_variables}%" if db_query.downcase.include?("like")
        return [db_query, bind_variables]
      end
    elsif bind_variables.kind_of?(Array)
      return [db_query, *bind_variables] if bind_variables and not bind_variables.empty?
    end
  end
  
  def format_conditions(conds)
    conds.compact! # remove nil entries
    conditions = [[]]
    conds.each do |c| 
      conditions.first << c.delete(c.first); 
      c.each{|e| conditions << e}
    end
    conditions[0] = conditions.first.join(" AND ")
    return conditions    
  end
end
#   
# end
