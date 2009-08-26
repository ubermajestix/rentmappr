module Stats
  def self.initialize
  end
  def self.get_stats(opts={})
    @houses = House.find_by_sql("select count(*) as count, geocoded from houses group by geocoded")
    output = []
    output << Time.now.to_s 
    @houses.each{|set| output << "Total #{set.geocoded}: #{set.count}"}

    output << areas if opts[:areas]
    output << last_12_hours if opts[:last_12]
    output << week  if opts[:week]
    output << total_by_day if opts[:total]
    
    return output.flatten.join(opts[:format] || "\n")
  end
  
  def self.time_output(houses)
    output = []
    map_areas = MapArea.all
    map_areas.each do |map_area|
      m=houses.select{|h| h.map_area_id == map_area.id}
      output << "---#{map_area.name}---"
      db_time_format = "%Y-%m-%d %H:%M:%S"
      m.sort{|a,b| DateTime.strptime(a.time, db_time_format)<=>DateTime.strptime(b.time, db_time_format)}.reverse.each{|set| output << "#{set.time} #{set.geocoded}: #{set.count.rjust(10 - set.geocoded.length)}"} 
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
    houses = House.find_by_sql("SELECT date_trunc('day', created_at) AS time, count(*) AS count, geocoded, map_area_id FROM houses WHERE created_at > now() - interval '1 week' GROUP BY geocoded, map_area_id, time  ORDER BY time asc")
    return time_output(houses)
  end
  
  def self.last_12_hours
    houses = House.find_by_sql("SELECT date_trunc('hour', created_at) AS time, count(*) AS count, geocoded, map_area_id FROM houses WHERE created_at > now() - interval '12 hours' GROUP BY geocoded, map_area_id, time  ORDER BY time desc")
    return time_output(houses)
  end
  
  def self.total_by_day
    output = []
    houses = House.find_by_sql("SELECT date_trunc('day', created_at) AS time, count(*) AS count, geocoded FROM houses WHERE created_at > now() - interval '1 week' GROUP BY geocoded, time  ORDER BY time desc")
    output << "=====Total by day====="
    houses.each{|set| output << "#{set.time} #{set.geocoded}: #{set.count.rjust(10 - set.geocoded.length)}"}
    return output
  end
end
