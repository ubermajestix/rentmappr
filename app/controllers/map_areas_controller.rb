class MapAreasController < ApplicationController
layout "map_area"
before_filter :admin_only
  def index
    @map_areas = MapArea.find(:all)
    @start = GeoLoc.new(:lat=>40.010492, :lng=> -105.276843)
    @zoom=13
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @map_areas }
    end
  end

  # GET /map_areas/1
  # GET /map_areas/1.xml
  def show
    @map_area = MapArea.find(params[:id])
    @start = @map_area
    @zoom= 4
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @map_area }
    end
  end

  # GET /map_areas/new
  # GET /map_areas/new.xml
  def new
    @map_area = MapArea.new
    @start = GeoLoc.new(:lat=>40.010492, :lng=> -105.276843)
    @zoom= 11
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
        format.html { redirect_to(@map_area) }
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
end
