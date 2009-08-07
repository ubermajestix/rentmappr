class AddAccuracy < ActiveRecord::Migration
  def self.up
    add_column :houses, :accuracy, :string
    
  end

  def self.down
  end
end
