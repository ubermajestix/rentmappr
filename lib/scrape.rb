#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'activerecord'
require 'rfuzz/client'
require 'net/http'
require 'logger'

ActiveRecord::Base.establish_connection(
                                        :adapter  => "mysql", 
                                        :host     => "localhost",
                                        :username => "root",
                                        :password => "",
                                        :database => "bldrcl", 
					:pool => 20, :wait_timeout => 15)

@start_run = Time.now

class House < ActiveRecord::Base
  validates_uniqueness_of :href, :address
  validates_presence_of :title, :href, :address
 # validates_length_of :address, :minimum=>10
end

class MapArea < ActiveRecord::Base
  has_many :houses
end

class GeoLoc
  attr_accessor :lat
  attr_accessor :lng
  attr_accessor :success
end



def flagged(title)
  title.include?("flagged")
end

def google_link(link)
  link.match(/maps.google/)
end

# geocode()
# exit

  
  def pet_threads(site, pet_type)
     puts "going to #{site}/search/apa?#{pet_type}"
       main_page = Hpricot(open("http://#{site}/search/apa?#{pet_type}"))
    # puts main_page.inspect  
      items = main_page.search("div.sh")
      bold_items = items.first.search("b")
      found = bold_items[1].inner_html.to_s
      found = found[found.index("Found:")+7...found.index("Displaying")]
     # get total results and pages
      pages = (found.to_f/100).floor
      urls = Queue.new
      pet_threads = []
      pages.times do |page|
        pet_threads << Thread.new("/search/apa?#{pet_type}&s=#{page}00", site) {|cl_page, cl_site|
          puts "scraping #{page} on #{cl_site}#{cl_page}"
          doc = Hpricot(open("http://#{cl_site}#{cl_page}"))
          #return all /apa/#{a number} formatted links
          doc.search("a") do |link|
            urls << "http://#{cl_site}#{link.get_attribute("href")}" if link.get_attribute("href").to_s.match(/([a-z]{3})([\/apa\/])([0-9])/)
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
  

  


#scrape links
def scrape_links(site)#returns queue
  links = Queue.new
  @cats = pet_threads(site, "addTwo=purrr")
  @dogs = pet_threads(site, "addThree=wooof")
  scraper_threads = []
  pages = []
  date = Time.now
  puts "hitting #{site}"
  10.times do |page|
  # while date > Time.now-7.days do |page|
    scraper_threads << Thread.new("/apa/index#{page}00.html", site) {|cl_page, cl_site|
      puts "scraping #{page} on #{cl_site}#{cl_page}"
    #  cl = RFuzz::HttpClient.new(cl_site, 80)
     # doc = Hpricot(cl.get(cl_page).http_body)
      doc = Hpricot(open("http://#{cl_site}#{cl_page}"))
      t_links = []
    doc.search("a") do |item|
      t_links << item.get_attribute("href") if item.get_attribute("href").to_s.match(/([a-z]{3})([\/apa\/])([0-9])/)
      
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
    house.bedrooms = house.title.match(/([0-9]br)/)
    
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
    puts house
    house.save
    puts "**"*45
 else
   puts "XX"*45
   puts house.errors.full_messages 
   puts "XX"*45
 end 
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
unless ARGV[0]
  @map_areas = MapArea.find(:all) 
else
  puts ARGV[0]
  @map_areas = MapArea.find_all_by_name(ARGV[0])
end

puts "scraping for #{@map_areas.length} cities"
for map_area in @map_areas.reverse 
  house_start = Time.now
  @houses = map_area.houses
  puts "#{@houses.length} in #{map_area.name}"
  #@houses.each { |house| house.destroy }
    puts "scraping #{map_area.craigslist}" 
     queue = scrape_links(map_area.craigslist)
     pull_down_page(queue, map_area)
     puts map_area.houses.length
     puts "took: #{Time.now - house_start}"
     puts "=="*45
     puts "=="*45
     puts "=="*45
     puts "=="*45
     puts "=="*45
end





@houses = House.find(:all)
s = f = n = 0
@houses.each { |house| 
n +=1  if house.geocoded == 'n' 
s +=1  if house.geocoded == 's' 
f +=1  if house.geocoded == 'f'  }
puts "failed: #{f}"
puts "success: #{s}"
puts "not yet: #{n}"
puts
puts "took: #{Time.now - @start_run}"
puts Time.now.strftime("%m/%d/%Y %H:%M")
