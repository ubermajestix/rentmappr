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
  
  def remove_center_match
    self.logger.info "Removing houses that match city center"
    #remove houses that match the city center
      @map_areas = opts[:city] ? MapArea.find_all_by_name(opts[:city]) : MapArea.find(:all) 
       for map_area in @map_areas.reverse
         @houses = map_area.houses
         self.logger.info "#{@houses.length} for #{map_area.name}"
         @houses.collect!{|h| h.destroy if h.matches_center}
         self.logger.info "removed matching center: #{map_area.houses.length} for #{map_area.name}"
       end
  end
    
  
  def scrape_links(map_area)#returns queue
    urls = []
    links = Queue.new
    scraper_threads = []
    pages = []
    puts "hitting #{map_area.scrape_url}"
    10.times do |page|
      scraper_threads << Thread.new("#{page}00.html", map_area) {|cl_page, map_area|
        begin
          puts "scraping page #{page} on #{map_area.scrape_url}#{cl_page}"
          cl = open("http://#{map_area.scrape_url}#{cl_page}")
          cl_string = cl.read
          if cl.status.first == "200" and not flagged?(cl_string) and not removed?(cl_string)
            doc = Hpricot(cl_string)
            t_links = []
            doc.search("a") do |item|
              t_links << item.get_attribute("href") if item.get_attribute("href").to_s.match(/([a-z]{3})([\/apa\/])([0-9])/)
            end      
            t_links.collect!{|t| "http://#{map_area.url}#{t}"}
            links << t_links unless t_links.empty?
            puts "found: #{t_links.length} links"
            ActiveRecord::Base.clear_active_connections!
          end # status == 200
        rescue StandardError => e
          logger.error e.inspect
        rescue Timeout::Error => e
          logger.error "Timeout! " + e.inspect
        end
      }
    end
    scraper_threads.each{|t| t.join}
    links.length.times do |batch_num|
      urls << links.deq
    end
    return urls.flatten
  end

end
