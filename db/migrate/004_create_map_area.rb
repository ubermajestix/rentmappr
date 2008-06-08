class CreateMapArea < ActiveRecord::Migration
  def self.up
    create_table :map_areas do |t|
      t.string :name
      t.string :craigslist
      t.integer :expires_in
      t.float :lat
      t.float :lng
      t.timestamps
    end
  end

  def self.down
    drop_table :map_areas
  end
end
