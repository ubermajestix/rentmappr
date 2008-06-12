# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    def online?
       begin
        open("http://www.google.com")
        online = true
      rescue Exception => e
        puts e
        online = false
      end
      online
    end
    
    def load_analytics?
      load = true
      if logged_in?
        if current_user.tyler?
          load = false
        end
      end
      load
    end
    
    def global_page_title
      "rentmappr - locate a house to rent listed on craigslist.org"
    end
end
