#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'activerecord'
Dir.glob("app/models/*.rb").sort.each {|rb| require rb}
require 'rfuzz/client'
require 'net/http'
require 'logger'
require 'rack'
class Geocode
  def initialize
    # @logger = logger
    logger.info "Craigslist Geocoding"
    # establish_database_connection
    @start_run = Time.now
    nil
  end
  attr_reader :start_run
  # public :initialize
  
  def logger
    return @logger if @logger
    Logging.appenders.stdout(:level => :debug,:layout => Logging.layouts.pattern(:pattern => '[%c:%5l] %p %d --- %m\n'))
    log = Logging.logger['RentmapprScraper']
    log.add_appenders 'stdout'
    @logger = log
  end
    
  def establish_database_connection
      logger.info "connecting to db"
    ActiveRecord::Base.establish_connection(
                                            :adapter  => "mysql", 
                                            :host     => "localhost",
                                            :username => "root",
                                            :password => "",
                                            :database => "bldrcl", 
    					:pool => 20, :wait_timeout => 15)
  end

class GeoLoc
  attr_accessor :lat
  attr_accessor :lng
  attr_accessor :success
end


# TODO add city specific lookup - get from command line

def geocode(houses)
  
  @houses = houses
  logger.info "geocoding: #{@houses.length}"
  #split into 10 batches
  #put batches onto queue
  #spawn threads - consume queue

  # geo_threads = []
  # 10.times do |batch_num| 
  #   length = @houses.length/10    
  #   batch = @houses[batch_num*length..(batch_num + 1)*length]
  #   logger.info "=="*45
  #     geo_threads << Thread.new(batch, batch_num){|t_houses, num|
  #      logger.info "in thread: #{num}"
     #  begin
        for house in @houses #t_houses
        loc = house.address ? geocodr(house.address) : GeoLoc.new()
        logger.info "   #{@houses.index(house)}/#{@houses.length}".rjust(10) if @houses.index(house)%5==0
        if loc.success
          print "."
          house.update_attributes(:lat=>loc.lat, :lng=>loc.lng, :geocoded=>"s")
         # sleep 1
        else
          print "X"
          #retry geocoding with at+some+street stripped out
          begin
          house.address = retry_address(house.address)
          loc = house.address ? geocodr(house.address) : GeoLoc.new()
           if loc.success
              print "+"
              house.update_attributes(:lat=>loc.lat, :lng=>loc.lng, :address=>house.address, :geocoded=>"s")
           else
             house.update_attribute(:geocoded, "f")
           end      
           rescue StandardError => e
             logger.fatal e.inspect
           end                        
        end #loc.succes 1st time
      end
    # rescue Exception => e
    #            logger.info e
    #     end
        #    }
    # end
    #geo_threads.each { |e| e.join }
end

def geocodr(address_str)
  #logger.info "getting xml: #{address_str}"
   @start = GeoLoc.new
   begin
    res = Hpricot.XML(open("http://maps.google.com/maps/geo?q=#{Rack::Utils.escape(address_str)}&output=xml&key=ABQIAAAA5KBnIbKAbVGi_wO_Q2EAghTJQa0g3IQ9GZqIMmInSLzwtGDKaBSJdHlrIYiFi9WNEHgJJlj6ZPq6Mw&oe=utf-8"))
    status = ""  
    res.search("code"){|d| status = d.inner_html}
    if status == "200"
     # logger.info "parsing xml"
     coords = []
     res.search("coordinates"){|l| coords = l.inner_html.split(",")} 
     @start.lat = coords[1]
     @start.lng = coords[0]
     @start.success = true
    end
  rescue StandardError => e
    logger.info e    
  rescue Timeout::Error => e
    logger.info e
  end
    @start
  
end

  def retry_address(address)
    raise "no adress to correct" unless address
    if address.match(/\+at\+/)
      if address.match(/([0-9])([\+])([A-Za-z])/)
        street = address[0...address.index("+at+")]
        print "-"
        csc = address.split("+")
        csc = csc[csc.length-3...csc.length]
        address = street + "+" + csc.join("+")
        address.gsub!(".","")
      end
    end
    address
  end
  
  def start_geocoding  
    @map_areas = MapArea.find(:all)
    for map_area in @map_areas 
      @houses = House.find(:all, :conditions => ["map_area_id = ? and geocoded = ?", map_area.id, 'n' ])
      geocode(@houses)  
    end  
  end
  
  def stats
    @houses = House.find(:all)
    s = f = n = 0
    @houses.each { |house| 
    n +=1  if house.geocoded == 'n' 
    s +=1  if house.geocoded == 's' 
    f +=1  if house.geocoded == 'f'  }
    logger.info "failed: #{f}"
    logger.info "success: #{s}"
    logger.info "not yet: #{n}"
    logger.info
    logger.info "took: #{Time.now - self.start_run}"
    logger.info Time.now.strftime("%m/%d/%Y %H:%M")
  end
end
