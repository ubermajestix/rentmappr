#!/usr/bin/env ruby

require 'rubygems'
require 'activerecord'
require 'jabber_logger'
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
    @the_log = []
    # Make Postgres 8.3 have array_agg:
    begin
      ActiveRecord::Base.connection.execute("CREATE AGGREGATE array_agg(anyelement) (SFUNC=array_append, STYPE=anyarray, INITCOND='{}');")
    rescue StandardError => e
      puts "array_agg already defined"
    end
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
  
  def timestamp(time=Time.now)
    # time||=Time.now
    time.strftime("%H:%M:%S %m/%d/%y")
  end
  
  def remove_matching_titles(opts={})
    @map_areas = opts[:city] ? MapArea.find_all_by_name(opts[:city]) : MapArea.find(:all)
    for map_area in @map_areas
      h = House.find_by_sql("select count(id) as count, array_to_string( array_agg(id), ',' ) as ids, title from houses where map_area_id=#{map_area.id} and geocoded != 'duplicate' group by title having count(id) > 1")
      removal_ids = []
      h.each do |set|
        ids = set.ids.split(",")
        ids.collect!{|id| id.to_i}
        max = ids.inject{|r,v| r<v ? r=v : r=r}
        ids.delete(max)
        removal_ids << ids
      end
      removal_ids.flatten!
      @the_log << "marking #{removal_ids.length} as duplicate for #{map_area.name}"
      update_statement = []
      removal_ids.length.times{|d| update_statement << {:geocoded=>'duplicate'}}
      House.update(removal_ids, update_statement)
    end
  end
 
  def remove_old(opts={})
    @map_areas = opts[:city] ? MapArea.find_all_by_name(opts[:city]) : MapArea.find(:all) 
    for map_area in @map_areas.reverse 
      expiration = Time.now - map_area.expires_in.days
      @houses = House.find(:all, :joins=>"left outer join userhouses on userhouses.house_id = houses.id", :conditions=>["map_area_id = #{map_area.id} and houses.updated_at <= ? and userhouses.saved is null", expiration])
      ids = @houses.map(&:id)
      update_statement = []
      ids.length.times{|d| update_statement << {:geocoded=>'old'}}
      House.update(ids, update_statement)
      @the_log << "#{timestamp}: removing #{@houses.length} houses #{map_area.craigslist} older than #{expiration}\n"   
      # Don't remove these! We're re-geocoding these every hour!
      # @houses = House.find(:all, :conditions=>["map_area_id = #{map_area.id} and geocoded = 'f'"])
      #      House.delete(@houses.map(&:id))
      #      mail << "#{timestamp}: removing #{@houses.length} houses #{map_area.craigslist} that didn't geocode\n"   
      
    end  
  end
  
  def remove_matches_center(opts={})
    self.logger.info "Removing houses that match city center"
    #remove houses that match the city center
    @map_areas = opts[:city] ? MapArea.find_all_by_name(opts[:city]) : MapArea.find(:all) 
    for map_area in @map_areas.reverse
      if map_area.center_lat and map_area.center_lng
        count = House.count(:conditions=>["lat = ? and lng = ? and map_area_id = ? and geocoded='s'", map_area.center_lat, map_area.center_lng, map_area.id])
        House.update_all("geocoded = 'center'", "lat = #{map_area.center_lat} and lng = #{map_area.center_lng} and map_area_id =#{map_area.id} and geocoded='s'")
        self.logger.info "deleted #{count} houses matching the center of #{map_area.name}"
        @the_log << "#{timestamp}: deleted #{count} houses matching the center of #{map_area.name}\n"
      else
        self.logger.error "no center coords for #{map_area.name}"
        @the_log << "#{timestamp} no center coords for #{map_area.name}\n"
      end
    end
  end
  
  def remove_flagged(opts={})
     self.logger.info "Removing houses that match city center"
      #remove houses that are flagged or removed
      @map_areas = opts[:city] ? MapArea.find_all_by_name(opts[:city]) : MapArea.find(:all) 
        for map_area in @map_areas.reverse
          queue = Queue.new
          houses = House.all(:conditions=>["map_area_id = #{map_area.id} and cl_removed is null and created_at >= ? and geocoded ='s'", Time.now - 1.days])
          @the_log << "checking #{houses.length} houses for #{map_area.name}"
          if houses.length > 0
            10.times{|n| queue << houses[n*11,houses.length/10]}
            parse_flagged(queue)
          end
      end    
      @the_log << "#{timestamp}: finished removed/flagged succesfully"
  end
  
  def parse_flagged(links)#pass queue
    addresses = []
    parser_threads = []
    links.length.times do |batch_num|
      cl_links = links.deq	
     	parser_threads << Thread.new(cl_links, batch_num){|t_links, num|
     	  removed = 0
     	  for house in t_links
     	    sleep 2 if t_links.index(house) % 10 == 0
     	    begin
     	      puts "#{t_links.index(house)} / #{num}:#{t_links.length} / #{removed}"
       	    cl = open(house.href, "User-Agent" => "Rentmappr.com/Ruby/#{RUBY_VERSION}")
            cl_string = cl.read
           
            if flagged?(cl_string) or removed?(cl_string)
              # see if house is saved... if not delete : if so update 
              removed += 1
               puts "#{house.href}"
               house.saved? ? house.update_attributes(:cl_removed=>true) : house.update_attributes(:geocoded=>'flagged')
               ActiveRecord::Base.clear_active_connections!
              # house.update_attributes(:cl_removed=>true)
            end 
          rescue OpenURI::HTTPError => e
            #we've been blocked!
            if e.message == "404 Not Found"
              logger.error "404 error: #{house.href}"
            elsif e.message == "403 Forbidden"
              #notify and sleep 5 minutes
              JabberLogger.send "#{timestamp}: Craigslist blocked us! record: #{t_links.index(house)} / Thread: #{num} / Removed: #{removed}"
              break
            end
          rescue StandardError => e
            logger.error e.inspect
            logger.error house.href
          rescue Timeout::Error => e
            logger.error "Timeout! " + e.inspect
          end    
     	  end
     	}
   end 
   parser_threads.each { |t| t.join }
  end#parse_flagged
    
  def send_log
    JabberLogger.send @the_log.join("\n")
  end

end
