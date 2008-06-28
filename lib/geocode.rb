#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'activerecord'
require 'rfuzz/client'
require 'net/http'
require 'logger'

@start_run = Time.now
ActiveRecord::Base.establish_connection(:adapter  => "mysql", 
                                        :host     => "localhost",
                                        :username => "root",
                                        :password => "",
                                        :database => "bldrcl")

class House < ActiveRecord::Base
end

class MapArea < ActiveRecord::Base
end

class GeoLoc
  attr_accessor :lat
  attr_accessor :lng
  attr_accessor :success
end


# TODO add city specific lookup - get from command line

def geocode(houses)
  
  @houses = houses
  puts "geocoding: #{@houses.length}"
  #split into 10 batches
  #put batches onto queue
  #spawn threads - consume queue

  # geo_threads = []
  # 10.times do |batch_num| 
  #   length = @houses.length/10    
  #   batch = @houses[batch_num*length..(batch_num + 1)*length]
  #   puts "=="*45
  #     geo_threads << Thread.new(batch, batch_num){|t_houses, num|
  #      puts "in thread: #{num}"
     #  begin
        for house in @houses #t_houses
        loc = house.address ? geocodr(house.address) : GeoLoc.new()
        puts "   #{@houses.index(house)}/#{@houses.length}".rjust(10) if @houses.index(house)%5==0
        if loc.success
          print "."
          house.update_attributes(:lat=>loc.lat, :lng=>loc.lng, :geocoded=>"s")
         # sleep 1
        else
          print "X"
          #retry geocoding with at+some+street stripped out
          house.address = retry_address(house.address)
          loc = house.address ? geocodr(house.address) : GeoLoc.new()
           if loc.success
              print "+"
              house.update_attributes(:lat=>loc.lat, :lng=>loc.lng, :address=>house.address, :geocoded=>"s")
           else
             house.update_attribute(:geocoded, "f")
           end                              
        end #loc.succes 1st time
      end
    # rescue Exception => e
    #            puts e
    #     end
        #    }
    # end
    #geo_threads.each { |e| e.join }
end

def geocodr(address_str)
  #puts "getting xml: #{address_str}"
   @start = GeoLoc.new
   begin
    res = Hpricot.XML(open("http://maps.google.com/maps/geo?q=#{CGI.escape(address_str)}&output=xml&key=ABQIAAAA5KBnIbKAbVGi_wO_Q2EAghTJQa0g3IQ9GZqIMmInSLzwtGDKaBSJdHlrIYiFi9WNEHgJJlj6ZPq6Mw&oe=utf-8"))
    status = ""  
    res.search("code"){|d| status = d.inner_html}
    if status == "200"
     # puts "parsing xml"
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

  def retry_address(address)
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
@map_areas = MapArea.find(:all)
  for map_area in @map_areas 
    @houses = House.find(:all, :conditions => ["map_area_id = ? and geocoded = ?", map_area.id, 'n' ])
    
    # @houses.length < 15000/@map_areas.length ? 
    geocode(@houses)  
    #: puts "too many results to geocode today"

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