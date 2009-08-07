class AddRegion < ActiveRecord::Migration
  def self.up
    add_column :map_areas, :region, :string
  end

  def self.down
  end
end
