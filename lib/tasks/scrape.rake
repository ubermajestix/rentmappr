namespace :cl do
  require "#{Dir.pwd}/lib/scrape"
  require "#{Dir.pwd}/lib/geocode"
  
  desc "scrape craigslist for houses"
  task :scrape do
    # @scraper = Scraper.initialize
    @scraper = Scraper.new
    @scraper.start_scraper
  end
  
  desc "geocode craigslist results"
  task :geocode do
    @geocoder = Geocode.new
    @geocoder.start_geocoding
  end
  
  desc "scrape and geocode craigslist results"
  task :scrape_and_geocode => [:scrape, :geocode] do
    @geocoder = Geocode.new
    @geocoder.start_geocoding
  end
end