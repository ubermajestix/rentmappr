class MapArea < ActiveRecord::Base
  has_many :houses
  before_save :set_official_center  
  validates_presence_of :address
  
  def set_official_center
    geoloc = Georb.geocodr(address)
    self.center_lat = geoloc.lat
    self.center_lng = geoloc.lng
  end
  
  def search_url
    self.craigslist + "/search/apa" + (self.region ? "/#{self.region}?" : "?")
  end
  
  def url
    self.craigslist #+ (self.region!="" ? "/#{self.region}" : '')
  end
  
  def scrape_url
    self.url + "/apa/index"
  end
end
