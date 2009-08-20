module Stats
  def self.initialize
  end
  def self.get_stats(opts={})
    @houses = House.find_by_sql("select count(*) as count from houses group by geocoded")
    output = []
    output << Time.now.to_s 
    @houses.each{|set| output << "Total Collected: #{set.count}"}

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
      m.collect{|d| d.time}.uniq.sort{|a,b| a<=>b }.each{|day| days[day]=m.select{|d| d.time==day}} 
      output << "---#{map_area.name}---"
      days.each_pair{|day, obj| obj.each{|set| output << "#{set.time}: #{set.count}"}}
    end
    return output
  end
  
  def self.areas
    areas = {}
    output = []
    houses=House.find_by_sql("select count(*) as count, map_area_id from houses group by map_area_id")
    houses.collect{|h| h.map_area.name}.uniq.each{|area| areas[area]=houses.select{|a| a.map_area.name == area }}
    areas.each_pair{|area, obj| obj.each{|set| output << "#{set.map_area.name}: #{set.count}" }}
    return output
  end
  
  def self.week
    houses = House.find_by_sql("SELECT date_trunc('day', created_at) AS time, count(*) AS count, map_area_id FROM houses WHERE created_at > now() - interval '1 week' GROUP BY map_area_id, time  ORDER BY time asc")
    return time_output(houses)
  end
  
  def self.last_12_hours
    houses = House.find_by_sql("SELECT date_trunc('hour', created_at) AS time, count(*) AS count, map_area_id FROM houses WHERE created_at > now() - interval '12 hours' GROUP BY map_area_id, time  ORDER BY time desc")
    return time_output(houses)
  end
end
