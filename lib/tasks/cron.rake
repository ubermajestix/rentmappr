task :cron  do
  Rake::Task['cl:scrape_and_geocode'].invoke
end