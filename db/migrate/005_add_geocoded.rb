class AddGeocoded < ActiveRecord::Migration
  def self.up
    add_column :houses, :geocoded, :string
    House.reset_column_information

    good = bad = 0
    @houses = House.find(:all)
    for house in @houses 
      puts "#{@houses.index(house)}/#{@houses.length} good: #{good}  bad: #{bad}"
      if house.lat && house.lng
        print " s"
        good += 1
        house.update_attribute(:geocoded, "s")
      else
        print " f"
        bad +=1
        house.update_attribute(:geocoded, "f")
      end
    end
  end

  

  def self.down
    remove_column :houses, :geocoded
  end
end
