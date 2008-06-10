require 'rubygems'
require 'activerecord'



ActiveRecord::Base.establish_connection(:adapter  => "mysql", 
                                        :host     => "localhost",
                                        :username => "root",
                                        :password => "",
                                        :database => "bldrcl")
                                        

class House < ActiveRecord::Base
end

class MapArea < ActiveRecord::Base
end

  @map_areas = MapArea.find(:all)
  for map_area in @map_areas 
    @old_houses = House.find(:all, :conditions => ["created_at < ?",(Time.now - map_area.expires_in*86400)])
    puts "found #{@old_houses.length} houses to destroy"
    
    #if any users have an old house saved, but not trashed, then keep it
    @user_houses = UserHouses.find(:all, :select=>"id", :conditions => ["trash != ?", true]).collect{|h| h.id}
    @old_houses.reject { |old_house| @user_houses.include?(old_house.id)  }
    puts "destroying #{@old_houses.length} old houses (with user saved houses excluded)"
    
    @bad_houses = House.find(:all, :conditions => ["geocoded = ?", 'f'])
    puts "found #{@bad_houses.length} to destroy..."
   
    @destroy_houses = @bad_houses + @old_houses
    puts "destroying houses now..."
    @destroy_houses.each { |house| house.destroy  }    
    
  end
  