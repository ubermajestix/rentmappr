# require 'rubygems'
# require 'activerecord'
# require ''
# Dir.glob("app/models/*.rb").sort.each {|rb| require rb}
# 
require 'jabber_logger'

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
    
    JabberLogger.send output.flatten.join(opts[:format] || "\n")
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
    # count houses for all areas, group by area
    houses=House.find_by_sql("select count(*) as count, map_area_id, geocoded from houses group by map_area_id,geocoded")
    for set in houses      
      output << "---#{set.map_area.name}---"
      output << "#{set.geocoded}: #{set.count}"
    end
    return output
  end
  
  def self.week
    output = []
    houses = House.find_by_sql("SELECT date_trunc('day', created_at) AS day, count(*) AS count, map_area_id, geocoded FROM houses WHERE created_at > now() - interval '1 week' GROUP BY map_area_id, day, geocoded  ORDER BY map_area_id, day, geocoded")
    #  7.times do |day| 
    #   houses = House.find(:all, :conditions => ["created_at <= ? and created_at >= ?",Time.now - day.days,  Time.now - (day+1).days])# 
    #   output << "---#{(Time.now - day.days).strftime('%m/%d/%y')}---"
    #   output << fspt(houses)
    # end
    for set in houses
      output << "---#{set.map_area.name}---"
      output << "#{set.day}"
      output << "#{set.geocoded}: #{set.count}"
    end
    return output
  end
  
  def self.last_12_hours
    output = []
    houses = House.find_by_sql("SELECT date_trunc('hour', created_at) AS hour, count(*) AS count, map_area_id, geocoded FROM houses WHERE created_at > now() - interval '12 hours' GROUP BY map_area_id, hour, geocoded  ORDER BY map_area_id, hour, geocoded")
    for set in houses
      output << "---#{set.map_area.name}---"
      output << "#{set.hour}"
      output << "#{set.geocoded}: #{set.count}"
    end
    # 12.times do |hour|
    #   hour-=1
    #   houses = House.find(:all, :conditions => ["created_at <= ? and created_at >= ?",Time.now - hour.hours, Time.now - (hour+1).hours]) 
    #   output << "--- #{(Time.now - hour.hours).strftime('%H:%M')} ---"
    #   output << fspt(houses)
    # end
    return output
  end
end
