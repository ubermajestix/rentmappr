class ChangeBedsToInteger < ActiveRecord::Migration
  def self.up
   remove_column :houses, :bedrooms
   add_column  :houses, :bedrooms, :integer, :default=>nil
   houses = House.all
   houses.each{|house| beds = t.title.downcase.scan(/[0-9]br/).first; puts "#{houses.index(house)}/#{houses.length}" unless beds.nil?; beds = beds.gsub(/\D/,'').to_i unless beds.nil?; house.update_attributes(:bedrooms=>beds.to_i) unless beds.nil?;}

    
      
      
      
    end
   end
  end

  def self.down
  end
end
