#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'activerecord'
require 'rfuzz/client'



start = Time.now

class House < ActiveRecord::Base
  
end

def flagged(title)
  title.include?("flagged")
end

def google_link(link)
  link.match(/maps.google/)
end

def process_pages(pages)
#  puts "processing: #{pages.length} first one: #{pages.first} "
  for link in pages
 #     puts "#{pages.index(link)} / #{pages.length}"
  #    puts link
      house = House.new
      house.href = "http://boulder.craigslist.org#{link}"
      hdoc = Hpricot(open("http://boulder.craigslist.org#{link}"))
      hdoc.search("a") do |goog|
   glink = goog.get_attribute("href").to_s if google_link(goog.get_attribute("href").to_s)
        if glink
      house.address = glink[glink.index("?q=loc")+10...glink.length] if glink.index("?q=loc")
        end
      end
  end
end

#scrape links
links = Queue.new
scraper_threads = []
pages = []
10.times do |page|
  pages << "/apa/index#{page}00.html"
end


 
for page in pages
  scraper_threads << Thread.new(page) {|cl_page|
    print "scraping #{page}"
    cl = RFuzz::HttpClient.new("boulder.craigslist.org", 80)
    doc = Hpricot(cl.get(cl_page).http_body)
    t_links = []
  doc.search("a") do |item|
    t_links << item.get_attribute("href") if item.get_attribute("href").to_s.match(/^\/apa\/([0-9])/)
  end
  links << t_links
  puts "found: #{t_links.length} links"
  }
end

scraper_threads.each{|t| t.join}

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
 addresses = []
 #FIXME temporary!!!!!!!
      ActiveRecord::Base.establish_connection(
                                              :adapter=>"mysql", 
                                              :host     => "localhost",
                                                 :username => "root",
                                                 :password => "",
                                                 :database => "bldrcl")
 House.destroy_all
cl_links = []
puts links
links.length.times do
	cl_links << links.deq	
end 
links = cl_links
links.flatten!
puts links.length
for link in links
   puts "#{links.index(link)} / #{links.length}"
   house = House.new
   puts house.href = "http://boulder.craigslist.org#{link}"
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
     puts house.images_href = table.to_s if table.to_s.match(/images.craigslist.com/)
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
 
 #geo locate
 #make call to rails app to geolocate
 puts "calling geolocation service"
 open("http://ubermajestix.com/houses/geocode"){|f|
   p f.content_type
   print f.read
 }
 puts "..."*10
 puts "took: #{Time.now - start}"
