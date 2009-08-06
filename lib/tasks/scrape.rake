namespace :cl do
  require "#{Dir.pwd}/lib/scrape"
  require "#{Dir.pwd}/lib/geocode"
  require "#{Dir.pwd}/lib/stats"
  
  desc "scrape craigslist for houses"
  task :scrape => :environment do
    # @scraper = Scraper.initialize
    @scraper = Scraper.new
    @scraper.start_scraper
  end
  
  desc "geocode craigslist results"
  task :geocode => :environment do
    @geocoder = Geocode.new
    @geocoder.start_geocoding
  end
  
  desc "scrape and geocode craigslist results"
  task :scrape_and_geocode => [:scrape, :geocode] do
    @geocoder = Geocode.new
    @geocoder.start_geocoding
  end
  
  desc "collection stats"
  task :stats => :environment do
    puts Stats.get_stats
  end
  
end