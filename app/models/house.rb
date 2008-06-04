class House < ActiveRecord::Base
  has_and_belongs_to_many :users,
    :foreign_key             => 'house_id', 
    :association_foreign_key => 'user_id', 
    :join_table              => :userhouses
   
  attr_accessor :saved
  attr_accessor :has_images
  validates_uniqueness_of :href
  validates_presence_of :title, :href, :price, :address
  
  def self.find_for_user( opts = {})

    
    # stash all houses in cache
    # update cache when insert is done from outside script
    # then get all houses from cache - price searching: reject houses that don't fall in range - that should be fast...
    # so has min reject if price < min_price
    # has max only reject price > max_price
    # has both price ! (min..max)
    puts "finding houses"
    houses = find(:all, :conditions=>opts[:conditions])
    user = opts[:user]
    if opts[:saved]
      #search for houses (above) and only return ones matching user
      houses.reject!{|house| not user.saved_houses.include?(house)}
    else
     #get rid of 'trashed' houses from the list
     puts "trashing"
      trashed = Userhouses.find_trashed_house_ids(:user_id=>user.id)
      houses.reject!{|h| trashed.include?(h.id)}
    end
    #tag the user's saved houses
    puts "looping"
    houses.each{|house| house.saved = true if user.saved_houses.include?(house)

   house.has_images = true if house.images_href
}
    houses
  end

end
