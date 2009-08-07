class MapArea < ActiveRecord::Base
  has_many :houses
  
  def search_url
    self.craigslist + "/search/apa" + (self.region ? "/#{self.region}?" : "?")
  end
  
  def url
    self.craigslist + (self.region ? "/#{self.region}" : '')
  end
  
  def scrape_url
    self.url + "/apa/index"
  end
end
