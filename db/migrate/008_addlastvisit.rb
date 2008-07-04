class Addlastvisit < ActiveRecord::Migration
  def self.up
    add_column :users, :last_visit, :datetime
  end

  def self.down
  end
end
