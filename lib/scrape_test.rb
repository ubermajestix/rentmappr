require "open-uri"
require "rubygems"
require 'hpricot'
require 'rfuzz/client'
require 'cgi'
require 'net/http'

#scrape links
links = Queue.new
scraper_threads = []
pages = []
page = 0
date = Time.now
days = 20
puts "find pages back to: #{Time.now - days*86400}"
while date > Time.now - days*86400 
  cl_page = "/apa/index#{page}00.html"
  # scraper_threads << Thread.new("/apa/index#{page}00.html") {|cl_page|
    puts "scraping #{cl_page}"
    cl = RFuzz::HttpClient.new("sfbay.craigslist.org", 80)
    doc = Hpricot(cl.get(cl_page).http_body)
    t_links = []
  doc.search("a") do |item|
    t_links << item.get_attribute("href") if item.get_attribute("href").to_s.match(/^\/apa\/([0-9])/)
  end
  doc.search("h4") do |page_date|
    puts page_date
    date_array = ParseDate.parsedate(page_date.inner_html.to_s)
    puts date = Time.local(Time.now.year, date_array[1], date_array[2])
  end
  links << t_links
 # puts "found: #{t_links.length} links"
  # puts "queue length: #{links.length}"
  # }
   page+=1
end

# scraper_threads.each{|t| t.join}
puts links.length

