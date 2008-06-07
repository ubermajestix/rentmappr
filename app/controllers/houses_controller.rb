class HousesController < ApplicationController

before_filter :login_required, :except=>"geocode"
layout "standard"  
  #TODO have user draw area on map in which they would like to search...awesome
  def index
    #TODO add price search

      cond_string = []
      cond_vars = []
      
      if params[:search]
        max_price = session[:max_price] = params[:max_price]
        min_price = session[:min_price] = params[:min_price]
      
        unless max_price.empty?
          cond_string << "price <= ?"
          cond_vars << max_price
        end
      
        unless min_price.empty?
          cond_string << "price >= ?"
          cond_vars << min_price
        end 
         @min_price = min_price
         @max_price = max_price
      end
      
      conds = []
      conds << cond_string.join(" and ")
      cond_vars.each { |var| conds << var  }

      @houses = House.find_for_user(:conditions=>conds, :user=>current_user, :saved=>params[:show_saved])
      #session[:houses] = @houses  
      @start = GeoLoc.new(:lat=>40.010492, :lng=> -105.276843)
      @show_saved = true if params[:show_saved]
      render :template => "houses/index"
  end
  
def remove_all_saved
  current_user.houses.each{|c| current_user.houses.delete(c) }
  current_user.save
  Userhouses.destroy_all
  redirect_to :action => "index"
end
  
  #FIXME ajax call to save it / trash it 
  
  
  def save_it
   @house = House.find(params[:id])    
    current_user.houses << @house unless current_user.houses.include?(@house)
    @house.update_attribute(:saved, true)
    current_user.save
      @houses = session[:houses]
    #TODO call rjs to remove marker, add it back as blue, then update short list
   # render :partial => "houses/short_list"
  end
  
  def remove_it
    #remove house from userhouses
    @house = House.find(params[:id])
    @house.update_attribute(:saved, false)
    current_user.houses.delete(@house)
    @houses = [] #session[:houses]
    #TODO call rjs to remove marker, add it back as pink, then update short list
  end
  
  def trash_it
    Userhouses.create(:user_id=>current_user.id, :house_id=>params[:id], :trash=>true)
    @house = House.find(params[:id])
    @house.update_attribute(:saved, false)
    @houses = session[:houses]
    @houses.delete(@house)
    #update short_list
    #update homes list
    #remove house from map
    #TODO call rjs to remove marker, update short list, update list
  end
  
  def show_images
    @house = House.find(params[:id])
    render :partial => "houses/images"
    
  end
  
  def bug_report
    render :template => "houses/bug_report", :layout=>"basic"
  end
  
  def file_bug
    @title = params[:title]
    @body = params[:body]
    Lighthouse.account = 'ubermajestix'
   Lighthouse.token = "4971a7da4778b8746c9fc63c9ac962fb9cf86259"

   @type = params[:type] == 'bug' ? 'bug' : 'feature request'

    ticket = Lighthouse::Ticket.new(:project_id => 12220)
     ticket.title = @title
     ticket.body = @body
     ticket.tags << 'user reported' << @type << current_user.email
     ticket.save

 flash[:notice] = "Successfully created ticket"
    redirect_to bug_report_path
  end
end
