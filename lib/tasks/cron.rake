task :cron  do
  begin
    Rake::Task['cl:scrape'].invoke
    Rake::Task['cl:geocode'].invoke
  rescue StandardError => e
    Rake::Task['cl:geocode'].invoke
  end
end