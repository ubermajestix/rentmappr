class HousesController < ApplicationController

before_filter :login_required, :only=>%w{save_it remove_it trash_it remove_all_saved}
layout "standard"  
  #TODO have user draw area on map in which they would like to search...awesome
  def index
     if session[:map_area_id]
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
      cond_string << "map_area_id = ?"
      cond_vars << session[:map_area_id]
      
      cond_string << "lat is not null and lng is not null"
      
      conds = []
      conds << cond_string.join(" and ")
      cond_vars.each { |var| conds << var  }
      if logged_in?
        @houses = House.find_for_user(:conditions=>conds, :user=>current_user, :saved=>params[:show_saved])
      else
        @houses = House.find(:all, :conditions => conds)
        @houses.each { |h| h.has_images=true if h.images_href }
      end
      #session[:houses] = @houses  
       @map_area = MapArea.find(session[:map_area_id])
      @start = GeoLoc.new(:lat=>@map_area.lat, :lng=> @map_area.lng)
      @houses_collected = House.count(:conditions => ["created_at >= ? and map_area_id = ?",midnight, @map_area.id])
      @zoom=6
      @show_saved = true if params[:show_saved]
      @house_count = @houses.length
      render :template => "houses/index"
    else
      redirect_to choose_city_path
    end
  end
  
  def choose_area
    @map_areas = MapArea.find(:all)
    @houses = House.count(:conditions => ["created_at >= ?",midnight])
    @start = GeoLoc.new(:lat=>40.08058466412761, :lng=>  -95.9765625)
    @zoom=13
    render :template => "houses/choose_area", :layout=>"choose_area"
  end  
  
  def test_marker
       @map_area = MapArea.find(session[:map_area_id])
       @start = GeoLoc.new(:lat=>@map_area.lat, :lng=> @map_area.lng)
      @zoom=6
      @houses = House.find(:all, :limit=>10)
      render :template => "houses/index", :layout=>"test_marker"
  end
  
  def load_info_window
     Userhouses.create(:user_id=>current_user.id, :house_id=>params[:house_id], :clicked=>true) if logged_in?
     @house = House.find(params[:house_id])
     @house.has_images = !@house.images_href.nil?
       @house.saved = current_user.saved_houses.include?(@house)
  end
  
  def pick_area
    session[:map_area_id] = params[:id]
    current_user.update_attribute(:map_area_id, params[:id]) if logged_in?
    redirect_to :action => "index"
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
    Userhouses.create(:user_id=>current_user.id, :house_id=>params[:id], :saved=>true)
    @house.update_attribute(:saved, true)
    @houses = session[:houses]
    @house.has_images = !@house.images_href.nil?
   
    #TODO call rjs to remove marker, add it back as blue, then update short list
   # render :partial => "houses/short_list"
  end
  
  def remove_it
    #remove house from userhouses
    @house = House.find(params[:id])
    @house.update_attribute(:saved, false)
    current_user.houses.delete(@house)
    @houses = [] #session[:houses]
     @house.has_images = !@house.images_href.nil?
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
  if params[:planet].downcase == "earth"
    if  !@title.empty? || !@body.empty?
    Lighthouse.account = 'ubermajestix'
    Lighthouse.token = "4971a7da4778b8746c9fc63c9ac962fb9cf86259"

     @type = params[:type] == 'bug' ? 'bug' : 'feature request'
     user = logged_in? ? current_user.email : (params[:email].empty? ? "unknown" : params[:email]) 
     ticket = Lighthouse::Ticket.new(:project_id => 12220)
     ticket.title = @title
     ticket.body = @body
     ticket.tags << 'user reported' << @type << user
     ticket.save

 flash[:notice] = "Successfully created ticket"
 else
   flash[:notice] = "You need to have either a title or body to submit"
 end
 else
   flash[:notice] = "you don't appear to be human, try again"
 end
    redirect_to bug_report_path
  end
end
