class CreateUserhouses < ActiveRecord::Migration
  def self.up
    create_table :userhouses do |t|
      t.integer :user_id
      t.integer :house_id
      t.boolean :trash
      t.timestamps
    end
  end

  def self.down
    drop_table :userhouses
  end
end
