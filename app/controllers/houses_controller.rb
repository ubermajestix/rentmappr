class HousesController < ApplicationController

before_filter :login_required, :only=>%w{remove_all_saved}
before_filter :setup_session
layout "standard"  
  #TODO have user draw area on map in which they would like to search...awesome
  def test
    @start = GeoLoc.new(:lat=>40.08058466412761, :lng=>  -95.9765625)
    @zoom=13
    render :template => "houses/test", :layout => "test"
  end
  def index
     if session[:map_area_id]
      conds = []
       if params[:search]
         params.each_pair{|k,v| session[k.to_sym]=v}
         conds << format_query("price <= ?", params[:max_price])
         conds << format_query("price >= ?", params[:min_price])
         if params[:bedrooms].to_i > -1
           conds << format_query("bedrooms <= ?", params[:bedrooms]) if params[:bedroom_operator] == "less"
           conds << format_query("bedrooms >= ?", params[:bedrooms]) if params[:bedroom_operator] == "more"
         end
         conds <<  ["dog is not null"] if params[:dog]
         conds <<  ["cat is not null"] if params[:cat]
       end
      conds << ["map_area_id  = #{session[:map_area_id]}"] 
      conds = format_conditions(conds)
      session[:search_conds] = conds unless conds.length == 1 
      conds = session[:search_conds] if params[:search].nil? and params[:page]
      session[:house_page] = params[:page]
 
      if logged_in?
        @houses = House.find_for_user(:conditions=>conds, :user=>current_user, :saved=>params[:show_saved])
        @total = House.count(:conditions => conds)
        @houses = House.paginate( 
          :finder        => :find_for_user,
          :conditions    => conds, 
          :user          => current_user,
          :total_entries => @total,
          :page          => params[:page], 
          :per_page      => 250
           )
      else
        @total = House.count(:conditions => conds)
        @houses = House.paginate(
          :finder => :find_for_session,
          :saved_ids => session[:saved_houses],
          :trashed_ids => session[:trashed_houses],
          :clicked_ids => session[:clicked_houses],
          :conditions    => conds,
          :order         => "created_at DESC",
          :total_entries => @total,
          :page          => params[:page], 
          :per_page      => 250
          )
        @houses.each { |h| h.has_images=true if h.images_href }
      end
      #session[:houses] = @houses  
      @map_area = MapArea.find(session[:map_area_id])
      @start = GeoLoc.new(:lat=>@map_area.lat, :lng=> @map_area.lng)
      @houses_collected = House.valid_total_for_area_today(@map_area)
      @zoom=6
      @house_count = @houses.length
      render :template => "houses/index"
    else
      redirect_to choose_city_path
    end
  end
  
  def clear_search
    puts "=="*45
    puts "=="*45
    puts "clearing session stuff for searching"
    puts "=="*45
    puts "=="*45
    session[:bedrooms], session[:cat], session[:dog], session[:min_price], session[:max_price] = nil 
    redirect_to :action => "index"
  end
  
  def info
    render :partial => "houses/info"
  end
  
  def choose_area
    @map_areas = MapArea.find(:all)
    @houses = House.count(:conditions => ["created_at >= ?",midnight])
    @start = GeoLoc.new(:lat=>40.08058466412761, :lng=>  -95.9765625)
    @zoom=13
    render :template => "houses/choose_area", :layout=>"choose_area"
  end    
  
  def pick_area
    session[:map_area_id] = params[:id]
    current_user.update_attribute(:map_area_id, params[:id]) if logged_in?
    redirect_to :action => "index"
  end
  
  def show_change_city
    @map_area = MapArea.find(session[:map_area_id])
    map_areas = MapArea.find(:all)
    @map_areas_hash = {}
    map_areas.each { |m| @map_areas_hash[m.name]=m.id }
    # render :partial => "change_city"
  end
  
  def city_details
    @houses = House.paginate(
      :conditions    => session[:house_conds],
      :order         => "created_at DESC",
      :total_entries => @total,
      :page          => session[:house_page], 
      :per_page      => 250
      )
    @houses.each { |h| h.has_images=true if h.images_href }
    @total = House.count(:conditions => session[:house_conds])
    @map_area = MapArea.find(session[:map_area_id])
    @houses_collected = House.valid_total_for_area_today(@map_area)
  end
  
  def test_marker
       @map_area = MapArea.find(session[:map_area_id])
       @start = GeoLoc.new(:lat=>@map_area.lat, :lng=> @map_area.lng)
      @zoom=6
      @houses = House.find(:all, :limit=>10)
      render :template => "houses/index", :layout=>"test_marker"
  end
  
  def load_info_window
     user = current_user || User.saved_user 
     Userhouses.create(:user_id=>user.id, :house_id=>params[:house_id], :clicked=>true)
     session[:clicked_houses] << params[:house_id]
     @house = House.find(params[:house_id])
     @house.has_images = !@house.images_href.nil?
     @house.saved = logged_in? ? current_user.saved_houses.include?(@house) : session[:saved_houses].include?(@house.id.to_s)
     @house.clicked = session[:clicked_houses].include?(@house.id.to_s)
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
    user = current_user || User.saved_user 
    Userhouses.create(:user_id=>user.id, :house_id=>params[:id], :saved=>true)
    session[:saved_houses] << params[:id]
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
    user = current_user || User.saved_user 
    user.houses.delete(@house)
    session[:saved_houses].delete(params[:id])
    @houses = [] #session[:houses]
    @house.has_images = !@house.images_href.nil?
    @house.clicked = session[:clicked_houses].include?(@house.id.to_s)
    
    #TODO call rjs to remove marker, add it back as pink, then update short list
  end
  
  def trash_it
    user = current_user || User.saved_user 
    Userhouses.create(:user_id=>user.id, :house_id=>params[:id], :trash=>true)
    session[:trashed_houses] << params[:id]
    @house = House.find(params[:id])
    @house.update_attribute(:saved, false)
    session[:saved_houses].delete(params[:id])
    @houses = session[:saved_houses]
    #update short_list
    #update homes list
    #remove house from map
    #TODO call rjs to remove marker, update short list, update list
  end
  
  def show_images
    @house = House.find(params[:id])
    render :partial => "houses/images"
  end
  
  def streetview
    @house = House.find(params[:id])
    render :partial => "houses/streetview"
  end
  
  def bug_report
    if params[:city]
      @title = "Please add me a city!"
      @body = "Hey Rentmappr,\n\r I'd like you to add my city: (your city here)\n\r Sincerely,\n (your name here)"
    end
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
        begin 
          raise "bug report: #{@title} \r\n #{@body}"
        rescue StandardError => e
          notify_hoptoad(e)
          redirect_to bug_report_path
        end
        
        # sends email with hoptoad instead?
      else
        flash[:notice] = "You need to have either a title or body to submit"
      end
    else
      flash[:notice] = "you don't appear to be human, try again"
    end    
  end
  
  def list
    @map_area = MapArea.find(params[:id])
    session[:list_map_id] = @map_area.id
    @houses = House.paginate(:all, :conditions=>{:map_area_id => @map_area.id}, :order=>"accuracy DESC", :page=>params[:page], :per_page=>30)
    render :template => "houses/list", :layout => "basic"
  end
  
  def search_list
    conds = []
    conds << format_query("map_area_id = ?", session[:list_map_id])
    conds << format_query("LOWER(title) like LOWER(?)", params[:title])
    conds << format_query("LOWER(href) like LOWER(?)", params[:href])
    conds << format_query("LOWER(address) like LOWER(?)", Rack::Utils.escape(params[:address]))
    # if params[:address] and not params[:address].empty?
    #   geo_loc = Georb.geocodr(params[:address])
    #   # search_bounds = [geo_loc.lat.to_f - 0.002, geo_loc.lat.to_f + 0.002, geo_loc.lng.to_f - 0.002, geo_loc.lng.to_f + 0.002  ]
    #   # conds << format_query("lat >= ? and lat<=? and lng >= ? and lng <= ?", search_bounds)
    #   search_bounds = [geo_loc.lat.to_f - 0.002, geo_loc.lat.to_f + 0.002 ]
    #   conds << format_query("lat >= ? and lat<=?", search_bounds)
    # end
    @map_area = MapArea.find(session[:list_map_id])
    @houses = House.paginate(:conditions=>format_conditions(conds), :page=>params[:page], :per_page=>30)
    render :template => "houses/list", :layout=>"basic"
  end
    
end
