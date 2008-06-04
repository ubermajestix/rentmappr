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
end
