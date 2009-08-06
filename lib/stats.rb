require 'rubygems'
require 'activerecord'
Dir.glob("app/models/*.rb").sort.each {|rb| require rb}



module Stats
  def self.initialize
  end
  def self.get_stats(format)
    @houses = House.find(:all)
    s = f = n = 0
    @houses.each { |house| 
    n +=1  if house.geocoded == 'n' 
    s +=1  if house.geocoded == 's' 
    f +=1  if house.geocoded == 'f'  }
    output = []
    output << Time.now.to_s 
    output << fspt(f, s, n, @houses.length.to_s)

    week = []
    7.times do |day|
      week << (Time.now - Time.now.sec - Time.now.min*60 - Time.now.hour*3600) - day*86400
    end

    for day in week 
      houses = House.find(:all, :conditions => ["created_at >= ? and created_at <= ?",day,  day+24*3600])# 
      output << "---#{day.strftime('%m/%d/%y')}---"
       s = f = n = 0
       houses.each { |house| 
       n +=1  if house.geocoded == 'n' 
       s +=1  if house.geocoded == 's' 
       f +=1  if house.geocoded == 'f'  }
       output << fspt(f, s, n, houses.length.to_s)
    end

    map_areas = MapArea.find(:all)
    for area in map_areas
      houses = area.houses
      output << "---#{area.name}---"
       s = f = n = 0
       houses.each { |house| 
       n +=1  if house.geocoded == 'n' 
       s +=1  if house.geocoded == 's' 
       f +=1  if house.geocoded == 'f'  }
       output << fspt(f, s, n, houses.length.to_s)
    end
    return output.flatten.join(format || "\n")
  end
  
  def self.fspt(f, s, n, h)
    output = []
    output << "failed: #{f.to_s.rjust(9)}"    
    output << "success: #{s.to_s.rjust(8)}"    
    output << "pending: #{n.to_s.rjust(8)}"
    output << "total: #{h.rjust(10)}"
    return output
  end
end
