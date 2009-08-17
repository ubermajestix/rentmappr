#!/usr/bin/env ruby

require 'rubygems'
require 'activerecord'
Dir.glob("app/models/*.rb").sort.each {|rb| require rb}
require 'open-uri'
require 'hpricot'


require 'rfuzz/client'
require 'net/http'
require 'logging'

class Remover

  def initialize
    # @logger = logger
    logger.info "Remover now ready to remove"
    # establish_database_connection
    @start_run = Time.now
    nil
  end
  attr_reader :start_run
  # public :initialize
  
  def logger
    return @logger if @logger
    Logging.appenders.stdout(:level => :debug,:layout => Logging.layouts.pattern(:pattern => '[%c:%5l] %p %d --- %m\n'))
    # TODO need email appender to send error messages
    log = Logging.logger['RentmapprRemover']
    log.add_appenders 'stdout'
    @logger = log
  end
    

  def flagged?(cl_string)
    match = cl_string.match "This posting has been <a href=\"http://www.craigslist.org/about/help/flags_and_community_moderation\">flagged</a> for removal"
    !!match
  end
  
  def removed?(cl_string)
    match = cl_string.match "This posting has been deleted by its author."
    !!match
  end
 
  def remove_old(opts={})
    @map_areas = opts[:city] ? MapArea.find_all_by_name(opts[:city]) : MapArea.find(:all) 
    for map_area in @map_areas.reverse 
      expiration = Time.now - map_area.expires_in.days
      @houses = House.find(:all, :joins=>"left outer join userhouses on userhouses.house_id = houses.id", :conditions=>["map_area_id = #{map_area.id} and houses.updated_at <= ? and userhouses.saved is null", expiration])
      puts "removing #{@houses.length} houses #{map_area.craigslist} older than #{expiration}"   
      @houses.each{|h| h.destroy}
    end   
  end
  
  def remove_matches_center(opts={})
    self.logger.info "Removing houses that match city center"
    #remove houses that match the city center
    @map_areas = opts[:city] ? MapArea.find_all_by_name(opts[:city]) : MapArea.find(:all) 
    for map_area in @map_areas.reverse
      destroyed = []
      @houses = map_area.houses
      self.logger.info "#{@houses.length} for #{map_area.name}"
      @houses.each{|h| if h.matches_center
        destroyed << h
        h.destroy 
        end}
      self.logger.info "removed #{destroyed.length} matching center for #{map_area.name}"
    end
  end
  
  def remove_flagged(opts={})
     self.logger.info "Removing houses that match city center"
      #remove houses that are flagged or removed
      @map_areas = opts[:city] ? MapArea.find_all_by_name(opts[:city]) : MapArea.find(:all) 
        for map_area in @map_areas.reverse
          queue = Queue.new
          houses = House.all(:conditions=>["map_area_id = #{map_area.id} and cl_removed is null"])
          puts "checking #{houses.length} houses for #{map_area.name}"
          10.times{|n| queue << houses[n*11,houses.length/10]}
          parse_flagged(queue)
      end    
  end
  
  def parse_flagged(links)#pass queue
    addresses = []
    parser_threads = []
    links.length.times do |batch_num|
      cl_links = links.deq	
     	parser_threads << Thread.new(cl_links, batch_num){|t_links, num|
     	  removed = 0
     	  for house in t_links
     	    begin
     	      puts "#{t_links.index(house)} / #{num} / #{removed}"
       	    cl = open(house.href)
            cl_string = cl.read        
            if flagged?(cl_string) or removed?(cl_string)
              # see if house is saved... if not delete : if so update 
              removed += 1
               puts "#{house.href}"
               house.saved? ? house.update_attributes(:cl_removed=>true) : house.destroy
               ActiveRecord::Base.clear_active_connections!
              # house.update_attributes(:cl_removed=>true)
            end 
          rescue StandardError => e
            logger.error e.inspect
          rescue Timeout::Error => e
            logger.error "Timeout! " + e.inspect
          end    
     	  end
     	}
   end 
   parser_threads.each { |t| t.join }
  end#parse_flagged
    

end
