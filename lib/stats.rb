# require 'rubygems'
# require 'activerecord'
# require ''
# Dir.glob("app/models/*.rb").sort.each {|rb| require rb}
# 


module Stats
  def self.initialize
  end
  def self.get_stats(opts={})
    @houses = House.find(:all)
    output = []
    output << Time.now.to_s 
    output << fspt(@houses)

    output << areas if opts[:areas]
    output << last_12_hours if opts[:last_12]
    output << week  if opts[:week]
    


    return output.flatten.join(opts[:format] || "\n")
  end
  
  def self.fspt(houses)
    output = []
    s = f = n = 0
    houses.each { |house| 
    n +=1  if house.geocoded == 'n' 
    s +=1  if house.geocoded == 's' 
    f +=1  if house.geocoded == 'f'  }
    output << "failed: #{f.to_s.rjust(9)}"    
    output << "success: #{s.to_s.rjust(8)}"    
    output << "pending: #{n.to_s.rjust(8)}"
    output << "total: #{houses.length.to_s.rjust(10)}"
    return output
  end
  
  def self.areas
    output = []
    map_areas = MapArea.find(:all)
    for area in map_areas
      houses = area.houses
      output << "---#{area.name}---"
      output << fspt(houses)
    end
    return output
  end
  
  def self.week
    output = []
     7.times do |day| 
      houses = House.find(:all, :conditions => ["created_at >= ? and created_at <= ?",Time.now - day.days,  Time.now - (day+1).days])# 
      output << "---#{(Time.now - day.days).strftime('%m/%d/%y')}---"
      output << fspt(houses)
    end
    return output
  end
  
  def self.last_12_hours
    output = []
    12.times do |hour|
      houses = House.find(:all, :conditions => ["created_at >= ? and created_at <= ?",Time.now - hour.hours, Time.now - (hour+1).hours]) 
      output << "--- #{(Time.now - hour.hours).strftime('%H:%M')} ---"
      output << fspt(houses)
    end
    return output
  end
end
