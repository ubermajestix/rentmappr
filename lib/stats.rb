require 'rubygems'
require 'activerecord'
require 'logger'


ActiveRecord::Base.establish_connection(:adapter  => "mysql", 
                                        :host     => "localhost",
                                        :username => "root",
                                        :password => "",
                                        :database => "bldrcl")

class House < ActiveRecord::Base
  belongs_to :map_area
end

class MapArea < ActiveRecord::Base
  has_many :houses
end


@houses = House.find(:all)
s = f = n = 0
@houses.each { |house| 
n +=1  if house.geocoded == 'n' 
s +=1  if house.geocoded == 's' 
f +=1  if house.geocoded == 'f'  }
puts Time.now
print "failed:"
puts f.to_s.rjust(8)
print "success:"
puts s.to_s.rjust(8)
print "pending:"
puts n.to_s.rjust(6)
print "total:"
puts "#{@houses.length}".rjust(10)
puts 

week = []
7.times do |day|
  week << (Time.now - Time.now.sec - Time.now.min*60 - Time.now.hour*3600) - day*86400
end

for day in week 
  houses = House.find(:all, :conditions => ["created_at >= ? and created_at <= ?",day,  day+24*3600])# 
  puts "---#{day.strftime('%m/%d/%y')}---"
   s = f = n = 0
   houses.each { |house| 
   n +=1  if house.geocoded == 'n' 
   s +=1  if house.geocoded == 's' 
   f +=1  if house.geocoded == 'f'  }
   print "failed:"
   puts f.to_s.rjust(8)
   print "success:"
   puts s.to_s.rjust(8)
   print "pending:"
   puts n.to_s.rjust(6)
   print "total:"
   puts "#{houses.length}".rjust(10)
end


puts 


map_areas = MapArea.find(:all)
for area in map_areas
  houses = area.houses
  puts "---#{area.name}---"
   s = f = n = 0
   houses.each { |house| 
   n +=1  if house.geocoded == 'n' 
   s +=1  if house.geocoded == 's' 
   f +=1  if house.geocoded == 'f'  }
   print "failed:"
   puts f.to_s.rjust(8)
   print "success:"
   puts s.to_s.rjust(8)
   print "pending:"
   puts n.to_s.rjust(6)
   print "total:"
   puts "#{houses.length}".rjust(10)

end
