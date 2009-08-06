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
  
  namespace :stats do
    desc "collection stats"
    task :all => :environment do
      puts Stats.get_stats(:week=>true, :last_12=>true, :area=>true)
    end
    desc "collection stats for the week"
    task :week => :environment do
      puts Stats.get_stats(:week=>true)
    end
    desc "collection stats for the day"
    task :day => :environment do
      puts Stats.get_stats(:last_12=>true)
    end
    desc "collection stats for areas"
    task :areas => :environment do
      puts Stats.get_stats(:areas=>true)
    end
  
  end
  
end