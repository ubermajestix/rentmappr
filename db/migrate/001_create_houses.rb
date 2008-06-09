class CreateHouses < ActiveRecord::Migration
  def self.up
    create_table :houses do |t|
      t.column :title, :string
      t.column :address, :string
      t.column :href, :string
      t.column :lat, :float
      t.column :lng, :float
      t.column :price, :int
      t.text :images_href
      t.integer :map_area_id
      t.timestamps
    end
  end

  def self.down
    drop_table :houses
  end
end
