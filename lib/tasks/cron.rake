task :cron  do
  begin
    Rake::Task['cl:remove_old'].invoke
  rescue
    begin    
      Rake::Task['cl:scrape'].invoke
      Rake::Task['cl:geocode'].invoke
    rescue
      Rake::Task['cl:geocode'].invoke
    end
  end
end