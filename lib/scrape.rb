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
require 'geo_loc'
require 'stats'

class Scraper

  def initialize
    # @logger = logger
    logger.info "Craigslist Scraping"
    # establish_database_connection
    @start_run = Time.now
    @the_log = []
    @hrefs_in_search = []
    nil
  end
  attr_reader :start_run
  # public :initialize
  
  def logger
    return @logger if @logger
    Logging.appenders.stdout(:level => :debug,:layout => Logging.layouts.pattern(:pattern => '[%c:%5l] %p %d --- %m\n'))
    # TODO need email appender to send error messages
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
      







  def flagged(title)
    title.include?("flagged")
  end

  def google_link(link)
    link.match(/maps.google/)
  end

  # geocode()
  # exit

  
    def pet_threads(map_area, pet_type)
        puts "going to http://#{map_area.search_url}#{pet_type}"
        main_page = Hpricot(open("http://#{map_area.search_url}#{pet_type}", "User-Agent" => "Rentmappr.com/Ruby/#{RUBY_VERSION}")) 
        items = main_page.search("div.sh")
        bold_items = items.first.search("b")
        found = bold_items[1].inner_html.to_s
        found = found[found.index("Found:")+7...found.index("Displaying")]
       # get total results and pages
        pages = (found.to_f/100).floor
        urls = Queue.new
        pet_threads = []
        pages.times do |page|
          pet_threads << Thread.new("#{pet_type}&s=#{page}00", map_area) {|cl_page, map_area|
            puts "scraping #{page} on #{map_area.search_url}#{cl_page}"
            doc = Hpricot(open("http://#{map_area.search_url}#{cl_page}", "User-Agent" => "Rentmappr.com/Ruby/#{RUBY_VERSION}"))
            #return all /apa/#{a number} formatted links
            doc.search("a") do |link|
              urls << "http://#{map_area.url}#{link.get_attribute("href")}" if link.get_attribute("href").to_s.match(/([a-z]{3})([\/apa\/])([0-9])/)
            end
          }
       end
       pet_threads.each{|t| t.join}
       pet_urls = []
       while !urls.empty?
         pet_urls << urls.deq
       end
       pet_urls
    end
  
    def flagged?(cl_string)
      match = cl_string.match "This posting has been <a href=\"http://www.craigslist.org/about/help/flags_and_community_moderation\">flagged</a> for removal"
      !!match
    end
    
    def removed?(cl_string)
      match = cl_string.match "This posting has been deleted by its author."
      !!match
    end

  #scrape links
  def scrape_links(map_area)#returns queue
    links = Queue.new
    @cats = pet_threads(map_area, "addTwo=purrr")
    @dogs = pet_threads(map_area, "addThree=wooof")
    scraper_threads = []
    pages = []
    date = Time.now
    puts "hitting #{map_area.scrape_url}"
    15.times do |page|
    # while date > Time.now-7.days do |page|
      scraper_threads << Thread.new("#{page}00.html", map_area) {|cl_page, map_area|
        begin
          puts "scraping page #{page} on #{map_area.scrape_url}#{cl_page}"
          cl = open("http://#{map_area.scrape_url}#{cl_page}", "User-Agent" => "Rentmappr.com/Ruby/#{RUBY_VERSION}")
          cl_string = cl.read
          if cl.status.first == "200" and not flagged?(cl_string) and not removed?(cl_string)
            doc = Hpricot(cl_string)
            t_links = []
            doc.search("a") do |item|
              t_links << item.get_attribute("href") if item.get_attribute("href").to_s.match(/([a-z]{3})([\/apa\/])([0-9])/)
            end      
            # here we want to only push urls onto the "links" Queue that we haven't seen
            logger.info "#{cl_page} tlinks before: " + t_links.length.to_s
            t_links.collect!{|t| "http://#{map_area.craigslist}#{t}"}
            seen_these_hrefs = House.all(:select=>"href", :conditions=>["href in (#{t_links.collect{|h| "'#{h}'"}.join(',')})"]).map(&:href)
            @hrefs_in_search << seen_these_hrefs          
            logger.info "seen em: " + seen_these_hrefs.length.to_s
            t_links = t_links - seen_these_hrefs
            logger.info "#{cl_page} tlinks after: " + t_links.length.to_s
            links << t_links unless t_links.empty?
            puts "found: #{t_links.length} links"
            puts "queue length: #{links.length}"
            ActiveRecord::Base.clear_active_connections!
          end # status == 200
        rescue OpenURI::HTTPError => e
          #we've been blocked!
          if e.message == "404 Not Found: #{house.href}"
            logger.error e.inspect
          elsif e.message. == "403 Forbidden"
             JabberLogger.send "Looks like cl shut us off."
              break
          else
            JabberLogger.send "Looks like cl shut us off? #{e.class}: #{e.message}"
            break
          end
        rescue StandardError => e
          logger.error e.inspect
        rescue Timeout::Error => e
          logger.error "Timeout! " + e.inspect
        end
      }
    end
    
    scraper_threads.each{|t| t.join}
    puts links.length
    links
  end

  def parse_cl_page(link, map_area)
   
     house = House.new
     house.href = link
     logger.info house.href
     cl = open("#{link}", "User-Agent" => "Rentmappr.com/Ruby/#{RUBY_VERSION}")
     cl_string = cl.read
     if cl.status.first == "200" and not flagged?(cl_string) and not removed?(cl_string)
       hdoc = Hpricot(cl_string)
       hdoc.search("a") do |goog|
         puts glink = goog.get_attribute("href").to_s if google_link(goog.get_attribute("href").to_s)
         if glink
           puts  house.address = glink[glink.index("?q=loc")+10...glink.length] if glink.index("?q=loc")
         end
       end
       # Find the title
       title = hdoc.search("h2").first
       puts title = title.inner_html.to_s
       title_end = title.index("(") ? title.index("(") : title.length
       puts house.title = title[0...title_end] unless flagged(title)
       house.title = house.title[0,255]
       puts house.price = house.title.match(/([\$])([0-9]{3,})/).to_s.gsub("$", "") if house.title && house.title.match(/([\$])([0-9]{3,})/)
       #find price in title $number 
       
       if house.valid?
           hdoc.search("table") do |table|
            images = []
             if table.to_s.match(/images.craigslist.org/)
               puts "finding images............"
               table.search("img") do |img|
                 puts img
                 images << img          
               end
               house.images_href = images.join("\n")
               puts house.images_href
             end
            end
 
        #set bedrooms
        beds = house.title.downcase.scan(/[0-9]br/).first
        house.bedrooms = beds.gsub(/\D/,'').to_i if beds
        studio = !!house.title.downcase.match(/studio/)
        house.bedrooms = 0 if studio
        #set dog and cat columns
        house.cat = true if @cats.include?(house.href)
        house.dog = true if @dogs.include?(house.href)
       if house.dog || house.cat
         puts "*^*"*45
         puts "cats: #{house.cat}"
         puts "dogs: #{house.dog}"
         puts "*^*"*45
       end
        #get email address and/or phone
        #pull down email address
        #look for phone number formatted text in description and title
    
        puts "map_area: #{map_area.id} | #{map_area.name}"
        house.map_area_id = map_area.id
        house.geocoded = 'n'
        puts house.inspect
        begin
          house.save
        rescue StandardError => e
          puts "X-"*45
          logger.error e.inspect
          puts "X-"*45
        end
        ActiveRecord::Base.clear_active_connections!
        puts "**"*45
     else
       puts "XX"*45
       puts house.errors.full_messages 
       puts "XX"*45
     end 
   end # status == 200 not flagged? not removed?
  rescue StandardError => e
    logger.error e.inspect
  rescue Timeout::Error => e
   puts e
  end#of parse_cl_page

  def pull_down_page(links, map_area)#pass queue
    addresses = []
    parser_threads = []
    links.length.times do |batch_num|
    #thread this
   	cl_links = links.deq	
   	puts "before flatten #{cl_links.inspect}"
   	parser_threads << Thread.new(cl_links, batch_num, map_area){|t_links, num, area|
   	  puts t_links.length
   	  for link in t_links
   	    puts "#{t_links.index(link)} / #{num}"
   	    parse_cl_page(link, area)
   	  end
   	  }
   end 
   parser_threads.each { |t| t.join }
  end#of pull down page 
 
  def start_scraper(opts={})
    logger.info ActiveRecord::Base.connection.instance_values["config"].inspect
    sleep 3
    @map_areas = opts[:city] ? MapArea.find_all_by_name(opts[:city]) : MapArea.find(:all) 
    self.logger.info "scraping for #{@map_areas.length} cities"
    # map_threads = []
    puts RUBY_VERSION
     for map_area in @map_areas.reverse 
       # map_threads << Thread.new(map_area){|tmap_area|
        tmap_area = map_area
        house_start = Time.now
        house_count = House.count(:conditions=>{:map_area_id=>tmap_area.id}).to_i 
        queue = scrape_links(tmap_area)
        pull_down_page(queue, tmap_area)
        new_house_count = House.count(:conditions=>{:map_area_id=>tmap_area.id}).to_i
        # we only really want to delete houses that aren't coming up in cl search results
        mark_old_houses_for_delete(tmap_area.id)
        @the_log << "#{timestamp}: Added #{new_house_count - house_count} houses for #{tmap_area.name} took: #{Time.now - house_start}"
      # }
     end
     # map_threads.each{|t| t.join}
     JabberLogger.send @the_log.join("\n")
  end
  
  def timestamp
    Time.now.strftime("%H:%M:%S")
  end
  
  def mark_old_houses_for_delete(map_area_id)
    #hrefs are still active in cl searches
    @houses = House.all(:conditions=>["href not in (?) and map_area_id = #{map_area_id} and geocoded = 'old'",@hrefs_in_search])
    ids = @houses.map(&:id)
    puts "found #{ids.length} houses to delete"
    update_statement = []
    ids.length.times{|d| update_statement << {:geocoded=>'delete'}}
    House.update(ids, update_statement)
  end
end
