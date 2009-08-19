task :cron  do
  begin
    # Rake::Task['cl:remove_old'].invoke
    # Rake::Task['cl:remove_center'].invoke
     Rake::Task['cl:remove_flagged'].invoke
  rescue
    begin    
      Rake::Task['cl:scrape'].invoke
      Rake::Task['cl:geocode'].invoke
    rescue
      Rake::Task['cl:geocode'].invoke
    end
  end
end