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
    MapArea.create "name"=>"boulder", "craigslist"=>"boulder.craigslist.org", "lng"=>-105.293, "id"=>1, "lat"=>39.9434, "expires_in"=>14
    MapArea.create "name"=>"denver", "craigslist"=>"denver.craigslist.org", "lng"=>-104.996, "id"=>2, "lat"=>39.7579, "expires_in"=>14
  end

  def self.down
    drop_table :map_areas
  end
end
