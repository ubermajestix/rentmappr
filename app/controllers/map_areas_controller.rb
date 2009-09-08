class MapAreasController < ApplicationController
layout "map_area"
before_filter :admin_only, :except=> [:st, :chart]
  def index
    @map_areas = MapArea.find(:all)
    @start = GeoLoc.new(:lat=>40.010492, :lng=> -105.276843)
    @zoom=13
    @stats = ""#Stats.get_stats(:areas=>true, :week=>true, :last_12=>true)
    puts @stats.length
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @map_areas }
    end
  end


  def st
    @stats = Stats.get_stats(:areas=>params[:areas], :week=>params[:week], :last_12=>params[:last_12])
    render :template => "map_areas/st", :layout=>false
  end
  # GET /map_areas/1
  # GET /map_areas/1.xml
  def show
    @map_area = MapArea.find(params[:id])
    @start = @map_area
    @zoom= 4
    @houses = House.count(:conditions => ["map_area_id = ?",params[:id]])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @map_area }
    end
  end

  def scrape
    @map_area = MapArea.find(params[:id])
   #  spawn do
   # puts "=="*45
   # 
   #   puts `ruby #{FileUtils.pwd}/lib/scrape.rb #{@map_area.id}`
   #  end
    puts "=="*45
    redirect_to :action => "show", :id=>params[:id]
  end
  # GET /map_areas/new
  # GET /map_areas/new.xml
  def new
    @map_area = MapArea.new
    @start = GeoLoc.new(:lat=>40.010492, :lng=> -105.276843)
    @zoom= 14
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @map_area }
    end
  end

  # GET /map_areas/1/edit
  def edit
    @map_area = MapArea.find(params[:id])
    @start = @map_area
    @zoom= 4
  end

  # POST /map_areas
  # POST /map_areas.xml
  def create
    @map_area = MapArea.new(params[:map_area])
    @map_area.craigslist = params[:map_area][:craigslist] + ".craigslist.org"
    respond_to do |format|
      if @map_area.save
        flash[:notice] = 'MapArea was successfully created.'
        format.html { redirect_to(@map_area) }
        format.xml  { render :xml => @map_area, :status => :created, :location => @map_area }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @map_area.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /map_areas/1
  # PUT /map_areas/1.xml
  def update
    @map_area = MapArea.find(params[:id])
    respond_to do |format|
      if @map_area.update_attributes(params[:map_area])
        flash[:notice] = 'MapArea was successfully updated.'
        format.html { redirect_to map_areas_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @map_area.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /map_areas/1
  # DELETE /map_areas/1.xml
  def destroy
    @map_area = MapArea.find(params[:id])
    @map_area.destroy

    respond_to do |format|
      format.html { redirect_to(map_areas_url) }
      format.xml  { head :ok }
    end
  end
  
  def charts
    puts "=="*45
    puts params[:city]
    puts "=="*45
    @data = []
   
    geocodes = %w"s f n duplicate delete flagged old"
    if params[:city] != -1 or not params[:city].nil?
      @data << "{data: #{Stats.week_overall(params[:city]).to_json} , label: 'total count'}"
      @city = params[:city]     
      geocodes.each do |g|
        @data << "{data: #{Stats.week_status(g, params[:city]).to_json} , label: '#{g} count'}"
      end
    else
      @city = -1
       @data << "{data: #{Stats.week_overall.to_json} , label: 'total count'}"
      geocodes.each do |g|
        @data << "{data: #{Stats.week_status(g).to_json} , label: '#{g} count'}"
      end
    end
    
    # @map_area = params[:id] ? MapArea.find(params[:id]): MapArea.first
    #    geocodes = House.find_by_sql("select distinct(geocoded) from houses where map_area_id = #{@map_area.id}").map(&:geocoded)
    #    data = House.find_by_sql("SELECT date_trunc('day', created_at) AS time, count(*) AS count FROM houses WHERE map_area_id = #{@map_area.id} and created_at > now() - interval '1 week' and geocoded = 's' group by time  ORDER BY time asc")
    #    # data = House.find_by_sql("SELECT date_trunc('day', created_at) AS time, count(*) AS count, geocoded FROM houses WHERE map_area_id = #{@map_area.id} and created_at > now() - interval '1 week' GROUP BY geocoded, time  ORDER BY time asc")
    #    
    #    # puts "=="*45
    #    #    puts data.inspect
    #    #    puts geocodes.inspect
    #    #    @data = {}
    #    #    geocodes.each do |geocode|
    #    #      set = data.select{|d| d.geocoded == geocode}
    #    #      @data[geocode] = set.collect{|s| [Time.parse(s.time).to_i*1000, s.count]}
    #    #    end
    #    #    puts "=="*45
    #    #    puts @data.inspect
    #    #    puts "=="*45
    #    @data = data.collect{|s| [Time.parse(s.time).to_i*1000, s.count]}

    render :template => "map_areas/charts", :layout=>false
  end
  
  
  
end
