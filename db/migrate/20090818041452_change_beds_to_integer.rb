class ChangeBedsToInteger < ActiveRecord::Migration
  def self.up
   remove_column :houses, :bedrooms
   add_column  :houses, :bedrooms, :integer, :default=>nil
   # houses = House.all
   # houses.each{|house| beds = house.title.downcase.scan(/[0-9]br/).first; puts "#{houses.index(house)}/#{houses.length}" unless beds.nil?; beds = beds.gsub(/\D/,'').to_i unless beds.nil?; house.update_attributes(:bedrooms=>beds.to_i) unless beds.nil?;}
   #    m = MapArea.find_by_name("denver")
   #    houses = House.valid_houses(:map_area=>m)
   #    house_beds = {}
   #    houses.each{|house| beds = house.title.downcase.scan(/[0-9]br/); house_beds[house.id]=beds.first.gsub(/\D/,'').to_i unless beds.first.nil?} 
   #    house_beds.each_pair{|key,value| House.find(key).update_attributes(:bedrooms=>value.to_i)}
   #    
   #    
    end
   end
  end

  def self.down
  end
end
