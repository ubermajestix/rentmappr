class AddPets < ActiveRecord::Migration
  def self.up
    add_column :houses, :dog, :boolean
    add_column :houses, :cat, :boolean
  end

  def self.down
  end
end
