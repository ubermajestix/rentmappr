class AddSavedUser < ActiveRecord::Migration
  def self.up
    User.create!(:login=>"saved", :password=>"savedUser", :password_confirmation=>"savedUser", :email=>"saved@rentmappr.com")
    User.create!(:login=>"tyler", :password=>"tyler", :password_confirmation=>"tyler", :email=>"tyler@rentmappr.com")
    
  end

  def self.down
  end
end
