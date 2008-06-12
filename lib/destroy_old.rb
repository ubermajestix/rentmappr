require 'rubygems'
require 'activerecord'



ActiveRecord::Base.establish_connection(:adapter  => "mysql", 
                                        :host     => "localhost",
                                        :username => "root",
                                        :password => "",
                                        :database => "bldrcl")
class Userhouses < ActiveRecord::Base
end                                        

class House < ActiveRecord::Base
end

class MapArea < ActiveRecord::Base
end

puts start = Time.now
    @user_houses = Userhouses.find(:all, :select=>"id", :conditions => ["trash != ?", true]).collect{|h| h.id}
  @map_areas = MapArea.find(:all)
  for map_area in @map_areas 
    @old_houses = House.find(:all, :conditions => ["created_at < ?",(Time.now - map_area.expires_in*86400)])
    puts "#{@old_houses.length} old houses for #{map_area.name}"
    
    #if any users have an old house saved, but not trashed, then keep it
    @old_houses.reject { |old_house| @user_houses.include?(old_house.id)  }
    puts "#{@old_houses.length} old houses (removed saved houses)"
    @old_houses.each{|house| house.destroy}   
 end
    @bad_houses = House.find(:all, :conditions => ["geocoded = ?", 'f'])
    puts "#{@bad_houses.length} bady houses to destroy..."
    @bad_houses.each { |house| house.destroy  }    
    
 puts "took: #{Time.now-start}" 
