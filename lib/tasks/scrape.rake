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
  end
  
  desc "remove old houses and check if remaining are flagged/removed"
  task :remove_flagged => :environment do 
    @remover = Remover.new
    map_area = MapArea.find_by_name("san francisco")
    urls = @remover.scrape_links(map_area)
    puts urls.inspect
    puts "=="*45
    puts urls.include?("http://boulder.craigslist.org/apa/1311570748.html")
    urls = @remover.scrape_links(map_area)
     removed = urls - map_area.houses.map(&:href)
     puts map_area.houses.length
     puts urls.length
     puts removed.length
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