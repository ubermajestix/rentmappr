class AddClicked < ActiveRecord::Migration
  def self.up
    add_column :userhouses, :saved, :boolean
    add_column :userhouses, :clicked, :boolean
    
    Userhouses.reset_column_information
    @houses = Userhouses.find(:all)
    
    for house in @houses
      unless house.trash
        house.update_attributes(:saved=>true)
      end
    end
    
  end

  def self.down
  end
end
