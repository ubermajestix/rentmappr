task :cron  do
  Rake::Task['cl:scrape'].invoke
  Rake::Task['cl:geocode'].invoke
  Rake::Task['cl:remove_old'].invoke
  Rake::Task['cl:remove_center'].invoke
  Rake::Task['cl:remove_flagged'].invoke
end
