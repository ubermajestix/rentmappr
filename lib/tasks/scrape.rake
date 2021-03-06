namespace :cl do
  require "#{Dir.pwd}/lib/scrape"
  require "#{Dir.pwd}/lib/geocode"
  require "#{Dir.pwd}/lib/remover"
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
  
  desc "remove old houses and check if remaining are flagged/removed"
  task :remove_old => :environment do 
    @remover = Remover.new
    @remover.remove_old
    @remover.send_log
  end
  
  desc "removes houses that match city center"
  task :remove_center => :environment do 
    @remover = Remover.new
    @remover.remove_matches_center()
    @remover.send_log
  end
  
  desc "remove old houses and check if remaining are flagged/removed"
  task :remove_flagged_one_off => :environment do 
    @remover = Remover.new
    @remover.remove_flagged
    @remover.send_log
    # @remover.remove_flagged if Time.now < (Time.now.midnight + 1.hour)
  end
  
  desc "remove old houses and check if remaining are flagged/removed"
  task :remove_flagged => :environment do 
    @remover = Remover.new
    @remover.remove_flagged if Time.now < (Time.now.midnight + 1.hour)
    @remover.send_log if Time.now < (Time.now.midnight + 1.hour)
    puts "not running this its not between midnight and 1am" unless Time.now < (Time.now.midnight + 1.hour)
  end
  
  desc "mark houses with matching titles as duplicates"
  task :remove_duplicates => :environment do 
    @remover = Remover.new
    @remover.remove_matching_titles
    @remover.send_log
  end
  
  namespace :stats do
    desc "collection stats"
    task :all => :environment do
      puts Stats.get_stats(:week=>true, :last_12=>true, :area=>true, :total=>true)
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
    desc "collection stats totals by day"
    task :total => :environment do
      puts Stats.get_stats(:total=>true)
    end
  
  end
  
end