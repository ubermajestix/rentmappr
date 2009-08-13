class AddOfficialCenter < ActiveRecord::Migration
  def self.up
    add_column :map_areas, :center_lat, :float
    add_column :map_areas, :center_lng, :float
    add_column :map_areas, :address,    :string
  end

  def self.down
    drop_column :map_areas, :center_lat
    drop_column :map_areas, :center_lng
    drop_column :map_areas, :address
  end
end
