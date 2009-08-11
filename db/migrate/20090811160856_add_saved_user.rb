class AddSavedUser < ActiveRecord::Migration
  def self.up
    User.create!(:login=>"saved", :password=>"savedUser", :password_confirmation=>"savedUser", :email=>"saved@rentmappr.com")
  end

  def self.down
  end
end
