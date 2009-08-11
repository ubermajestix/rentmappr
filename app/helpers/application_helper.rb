# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

    def online?
       begin
        open("http://www.google.com")
        online = true
      rescue StandardError => e
        puts e
        online = false
      end
      online
    end
    
    def nice_time(time)
      if time.kind_of? Time
        "#{time_ago_in_words(time)} ago."
      else
        ""
      end
    end
    
    def numeric_time(time)
      time.kind_of?(Time) ? "#{time.strftime('%d/%m/%y %H:%M')}" : ""
    end
    
    def load_analytics?
      load = true
      load = false if request.host.match(/localhost/)
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
    
    def bedroom_select( name, selected )
      #return populated select tag
      #maybe options should be populated from unique set of housing for each city...
      options = ["", "1br", "2br","3br","4br", "5br", "6br"]
      select_tag(name, options_for_select(options, selected))
    end
    
    def tybox_to_remote(name, options = {}, html_options = nil)
      options.update( :update=>"lightboxImage", 
                      :loading=>"Lightbox.prototype.start();", 
                      :failure=>"Lightbox.prototype.end();", 
                      :complete=>"Lightbox.prototype.resizeContainer(#{options[:width] || 350}, #{options[:height] || 200});")
      link_to_function(name, remote_function(options), html_options || options.delete(:html))      
    end
    
    def saved_houses
      houses = [] 
      houses << current_user.saved_houses if logged_in?
      houses << House.find(session[:saved_houses]) if session[:saved_houses]
      houses.flatten.uniq
    end
    


end
