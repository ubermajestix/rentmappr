class Userhouses < ActiveRecord::Base
  # belongs_to :users
  # belongs_to :houses
  
  def self.find_trashed_house_ids( opts = {})
    find(:all, :conditions => ["user_id = ? and trash = ?",opts[:user_id], true]).collect{|c| c.house_id}
  end
  
  def self.find_clicked_house_ids( opts = {})
     find(:all, :conditions => ["user_id = ? and clicked = ?",opts[:user_id], true]).collect{|c| c.house_id}
   end
   
   def self.find_saved_house_ids( opts = {})
      find(:all, :conditions => ["user_id = ? and saved = ?",opts[:user_id], true]).collect{|c| c.house_id}
    end
end
