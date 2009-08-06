task :cron  do
  begin
    Rake::Task['cl:scrape'].invoke
    Rake::Task['cl:geocode'].invoke
  rescue
    Rake::Task['cl:geocode'].invoke
  end
end