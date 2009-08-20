module Stats
  def self.initialize
  end
  def self.get_stats(opts={})
    @houses = House.find_by_sql("select count(*) as count, geocoded from houses group by geocoded")
    output = []
    output << Time.now.to_s 
    @houses.each{|set| output << "#{set.geocoded}: #{set.count}"}

    output << areas if opts[:areas]
    output << last_12_hours if opts[:last_12]
    output << week  if opts[:week]
    
    return output.flatten.join(opts[:format] || "\n")
  end
  
  def self.time_output(houses)
    output = []
    map_areas = MapArea.all
    map_areas.each do |map_area|
      days = {}
      m=houses.select{|h| h.map_area_id == map_area.id}
      m.collect{|d| d.day}.uniq.reverse.each{|day| days[day]=m.select{|d| d.day==day}} 
      output << "---#{map_area.name}---"
      days.each_pair{|day, obj| output << "--#{day}--"; obj.each{|set| output << "#{set.geocoded}: #{set.count}"}}
    end
    return output
  end
  
  def self.areas
    areas = {}
    output = []
    houses=House.find_by_sql("select count(*) as count, map_area_id, geocoded from houses group by map_area_id,geocoded")
    houses.collect{|h| h.map_area.name}.uniq.each{|area| areas[area]=houses.select{|a| a.map_area.name == area }}
    areas.each_pair{|area, obj| output << "---#{area}---"; obj.each{|set| output << "#{set.geocoded}: #{set.count}" }}
    return output
  end
  
  def self.week
    houses = House.find_by_sql("SELECT date_trunc('day', created_at) AS day, count(*) AS count, map_area_id, geocoded FROM houses WHERE created_at > now() - interval '1 week' GROUP BY map_area_id, day, geocoded  ORDER BY map_area_id, day, geocoded")
    return time_format(houses)
  end
  
  def self.last_12_hours
    houses = House.find_by_sql("SELECT date_trunc('hour', created_at) AS hour, count(*) AS count, map_area_id, geocoded FROM houses WHERE created_at > now() - interval '12 hours' GROUP BY map_area_id, hour, geocoded  ORDER BY map_area_id, hour, geocoded")
    return time_format(houses)
  end
end
