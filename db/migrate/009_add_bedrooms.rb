class AddBedrooms < ActiveRecord::Migration
  def self.up
    add_column :houses, :bedrooms, :string
  end

  def self.down
  end
end
