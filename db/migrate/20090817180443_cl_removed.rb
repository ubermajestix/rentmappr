class ClRemoved < ActiveRecord::Migration
  def self.up
    add_column :houses, :cl_removed, :boolean, :defalut=>false
  end

  def self.down
  end
end
