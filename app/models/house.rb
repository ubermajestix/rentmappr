class House < ActiveRecord::Base
  has_and_belongs_to_many :users,
    :foreign_key             => 'house_id', 
    :association_foreign_key => 'user_id', 
    :join_table              => :userhouses
    belongs_to :map_area
  attr_accessor :saved
  attr_accessor :clicked
  attr_accessor :has_images
 # validates_uniqueness_of :href
#  validates_presence_of :title, :href, :price, :address
 # validates_length_of :address, :minimum=>10
 
  def self.saved(user)
    find(Userhouses.find_saved_house_ids(:user_id=>user.id))
  end
  
  def self.find_for_user( opts = {})

    
    # stash all houses in cache
    # update cache when insert is done from outside script
    # then get all houses from cache - price searching: reject houses that don't fall in range - that should be fast...
    # so has min reject if price < min_price
    # has max only reject price > max_price
    # has both price ! (min..max)
    puts "finding houses"
    user = opts[:user]
     houses = find(
                    :all, 
                    :conditions=>opts[:conditions],
                    :offset => opts[:offset],
                    :limit  => opts[:limit], 
                    :order=>"created_at DESC")
    if opts[:saved] && user
     
      houses.collect!{|house| house if user.saved_houses.include?(house)}
    elsif user
    
      #search for houses (above) and only return ones matching user
      
    
     #get rid of 'trashed' houses from the list
      saved =  Userhouses.find_saved_house_ids(:user_id=>user.id)
      trashed = Userhouses.find_trashed_house_ids(:user_id=>user.id)
      clicked = Userhouses.find_clicked_house_ids(:user_id=>user.id)
      houses.reject!{|h| trashed.include?(h.id)}
     houses.each do |house|
       house.saved =  saved.include?(house.id)    
       house.clicked =  clicked.include?(house.id)
             
     end
      
    end
    #tag the user's saved houses
    
houses.each{|house|  house.has_images = true if house.images_href}
    houses
  end

end
