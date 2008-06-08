#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'activerecord'
require 'rfuzz/client'
require 'net/http'

ActiveRecord::Base.establish_connection(
                                        :adapter=>"mysql", 
                                        :host     => "localhost",
                                           :username => "root",
                                           :password => "",
                                           :database => "bldrcl")

@start_run = Time.now

class House < ActiveRecord::Base
  validates_uniqueness_of :href
  validates_presence_of :title, :href, :address
 # validates_length_of :address, :minimum=>10
end

class MapArea < ActiveRecord::Base
end

class GeoLoc
  attr_accessor :lat
  attr_accessor :lng
  attr_accessor :success
end


# TODO add city specific lookup - get from command line

def geocode
  
  @houses = House.find(:all)
  #split into 10 batches
  #put batches onto queue
  #spawn threads - consume queue

  geo_threads = []
  10.times do |batch_num| 
    length = @houses.length/10    
    batch = @houses[batch_num*length..(batch_num + 1)*length]
    puts "=="*45
      geo_threads << Thread.new(batch, batch_num){|t_houses, num|
       puts "in thread: #{num}"
        begin
        for house in t_houses
                puts "on house #{house.id}"
                puts "geocode it:  #{house.address}"
                loc = house.address ? geocodr(house.address) : GeoLoc.new()
                if loc.success
                  puts "saving house"
                  puts loc
                  house.update_attributes(:lat=>loc.lat, :lng=>loc.lng)
                else
                  puts "destroying house"
                  house.destroy
                  puts House.count
                end
                  # #try call again without the "at+some+street"
                  #               #address upto at
                  #               #find +city+state+us
                  #               # a1 = "3655+Clover+Creek+Ln.+at+Airport+SW+Longmont+CO+US"
                  #               # a2 = "3025+Broadway+at+Dellwood+Boulder+CO+US"
                  #               puts "."*20
                  #           if house.address.include?("+at") && house.address.match(/([0-9])([\+])([A-Za-z])/)
                  #               a1 = house.address
                  #               puts a1
                  #               address = a1[0...a1=~(/\+at/)]
                  #               puts address
                  #               city_state_country = a1[a1=~(/\+at/)...a1.length].split("+")
                  #               puts city_state_country
                  #               city_state_country = city_state_country[city_state_country.length-3...city_state_country.length] if city_state_country.length > 3
                  #               city_state_country = city_state_country.join("+")
                  #               house.address = address + "+"+city_state_country
                  #             else
                  #               house.address = nil
                  #             end
                  #               puts "regeocodeing: #{house.address}"
                  #               loc = house.address ? geocodr(house.address) : GeoLoc.new()
                  #                 if loc.success
                  #                   puts "saving house"
                  #                   puts loc
                  #                   house.update_attributes(:lat=>loc.lat, :lng=>loc.lng, :address=>house.address)
                  #                 else
                  #                   puts "destroying house"
                  #                   house.destroy
                  #                 end
                  #  end
              end
         rescue Exception => e
                   puts e
                  end
        }
    end
    geo_threads.each { |e| e.join }
end

def geocodr(address_str)

  puts "getting xml: #{address_str}"
   @start = GeoLoc.new
   begin
    res = Hpricot.XML(open("http://maps.google.com/maps/geo?q=#{CGI.escape(address_str)}&output=xml&key=ABQIAAAA5KBnIbKAbVGi_wO_Q2EAghTJQa0g3IQ9GZqIMmInSLzwtGDKaBSJdHlrIYiFi9WNEHgJJlj6ZPq6Mw&oe=utf-8"))
    status = ""  
    res.search("code"){|d| status = d.inner_html}
    if status == "200"
      puts "parsing xml"
     coords = []
     res.search("coordinates"){|l| coords = l.inner_html.split(",")} 
     @start.lat = coords[1]
     @start.lng = coords[0]
     @start.success = true
    end
  rescue Exception => e
    puts e    
  rescue Timeout::Error => e
    puts e
  end
    @start
  
end

def flagged(title)
  title.include?("flagged")
end

def google_link(link)
  link.match(/maps.google/)
end

# geocode()
# exit

#scrape links
def scrape_links(site)#returns queue
  links = Queue.new
  scraper_threads = []
  pages = []
  date = Time.now
  puts "hitting #{site}"
  15.times do |page|
  # while date > Time.now-7.days do |page|
    scraper_threads << Thread.new("/apa/index#{page}00.html", site) {|cl_page, cl_site|
      puts "scraping #{page} on #{cl_site}"
      cl = RFuzz::HttpClient.new(cl_site, 80)
      doc = Hpricot(cl.get(cl_page).http_body)
      t_links = []
    doc.search("a") do |item|
      t_links << item.get_attribute("href") if item.get_attribute("href").to_s.match(/^\/apa\/([0-9])/)
    end
    # doc.search("h4") do |page_date|
    #   date_array = parsedate(page_date.to_s)
    #   date = Time.local(Time.now.year, date_array[1], date_array[2])
    # end
    links << t_links
    puts "found: #{t_links.length} links"
    puts "queue length: #{links.length}"
    }
  end

  scraper_threads.each{|t| t.join}
  puts links.length
  links
end

def parse_cl_page(link, map_area)
   
   house = House.new
   puts house.href = "http://#{map_area.craigslist}#{link}"
   begin
   hdoc = Hpricot(open("http://#{map_area.craigslist}#{link}"))
   hdoc.search("a") do |goog|
     puts glink = goog.get_attribute("href").to_s if google_link(goog.get_attribute("href").to_s)
     if glink
       puts  house.address = glink[glink.index("?q=loc")+10...glink.length] if glink.index("?q=loc")
     end
   end
   hdoc.search("h2") do |title|
     puts title = title.inner_html.to_s
     title_end = title.index("(") ? title.index("(") : title.length
     puts house.title = title[0...title_end] unless flagged(title)
     puts house.price = house.title.match(/([\$])([0-9]{3,})/).to_s.gsub("$", "") if house.title && house.title.match(/([\$])([0-9]{3,})/)
     #find price in title $number 
   end

   
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
     puts "map_area: #{map_area.id} | #{map_area.name}"
   house.map_area_id = map_area.id
   if house.valid?
     puts "!!!yes!!"
   puts house
   house.save
   puts "**"*45
 else
   puts "XX"*45
   puts house.errors.full_messages 
      puts "XX"*45
 end
   
 end
 rescue Timeout::Error => e
   puts e
 end
end#of parse_cl_page

def pull_down_page(links, map_area)#pass queue
  addresses = []
#FIXME temporary!!!!!!!     
House.destroy_all
 
 parser_threads = []
 links.length.times do |batch_num|
   #thread this
 	cl_links = links.deq	
 	puts "before flatten #{cl_links.inspect}"

 puts cl_links.length
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

@map_areas = MapArea.find(:all)

@map_areas.each { |e| puts e.name + " | " + e.craigslist }
for map_area in @map_areas
  puts "scraping #{map_area.craigslist}" 
  queue = scrape_links(map_area.craigslist)
  pull_down_page(queue, map_area)
  puts House.count
  sleep 2
  geocode()
end



puts "took: #{Time.now - @start_run}"