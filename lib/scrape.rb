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
                puts "geocode it: #{house.id} #{house.address}"
                loc = house.address ? geocodr(house.address) : GeoLoc.new()
                if loc.success
                  puts "saving house"
                  puts loc
                  house.update_attributes(:lat=>loc.lat, :lng=>loc.lng)
                else
                  puts "destroying house"
                  house.destroy
                end
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
links = Queue.new
scraper_threads = []
pages = []
date = Time.now
while date > Time.now-7.days do |page|
  scraper_threads << Thread.new("/apa/index#{page}00.html") {|cl_page|
    print "scraping #{page}"
    cl = RFuzz::HttpClient.new("boulder.craigslist.org", 80)
    doc = Hpricot(cl.get(cl_page).http_body)
    t_links = []
  doc.search("a") do |item|
    t_links << item.get_attribute("href") if item.get_attribute("href").to_s.match(/^\/apa\/([0-9])/)
  end
  doc.search("h4") do |page_date|
    date_array = parsedate(page_date.to_s)
    date = Time.local(Time.now.year, date_array[1], date_array[2])
  end
  links << t_links
  puts "found: #{t_links.length} links"
  puts "queue length: #{links.length}"
  }
end

scraper_threads.each{|t| t.join}
puts links.length

#process_threads = []
#links.length.times do
#    puts links.length
#    cl_links = links.deq
#    process_threads << Thread.new(cl_links){|pages| 
#      ActiveRecord::Base.establish_connection(
#                                              :adapter=>"mysql", 
#                                              :host     => "localhost",
#                                                 :username => "root",
#                                                 :password => "",
#                                                 :database => "bldrcl")
#       cl = RFuzz::HttpClient.new("boulder.craigslist.org", 80)
#       for link in pages
#         puts link
#            house = House.new
#            house.href = "http://boulder.craigslist.org#{link}"      
#            doc = Hpricot(cl.get(link).http_body)           
#            doc.search("a") do |goog|
#              glink = goog.get_attribute("href").to_s if google_link(goog.get_attribute("href").to_s)
#              if glink
#               house.address = glink[glink.index("?q=loc")+10...glink.length] if glink.index("?q=loc")
#              end
#           end
#       end
#     }
#     ActiveRecord::Base.remove_connection
#end
#process_threads.each{|t| t.join}
#    
#follow links

def parse_cl_page(link)
   
   house = House.new
   puts house.href = "http://boulder.craigslist.org#{link}"
   begin
   hdoc = Hpricot(open("http://boulder.craigslist.org#{link}"))
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
   
   if house.valid?
     puts "!!!yes!!"
   puts house
   house.save
   puts "**"*45
 else
   puts "nope"
   puts "XX"*45
 end
   
 end
 rescue Timeout::Error => e
   puts e
 end
end

  addresses = []


#FIXME temporary!!!!!!!     
House.destroy_all
 
 parser_threads = []
 links.length.times do |batch_num|
   #thread this
 	cl_links = links.deq	
 	puts "before flatten #{cl_links.inspect}"

 puts cl_links.length
 	parser_threads << Thread.new(cl_links, batch_num){|t_links, num|
 	  puts t_links.length
 	  for link in t_links
 	    puts "#{t_links.index(link)} / #{num}"
 	    parse_cl_page(link)
 	  end
 	  }
 end 
 parser_threads.each { |t| t.join }
 
geocode()

puts "took: #{Time.now - @start_run}"