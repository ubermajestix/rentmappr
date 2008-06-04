require "open-uri"
require "rubygems"
require 'hpricot'
require 'rfuzz/client'
require 'cgi'
require 'net/http'

key = "ABQIAAAA5KBnIbKAbVGi_wO_Q2EAghTJQa0g3IQ9GZqIMmInSLzwtGDKaBSJdHlrIYiFi9WNEHgJJlj6ZPq6Mw&oe=utf-8"
address_str="1601 pearl st, boulder, co"
#Net::HTTP.get_print 'maps.google.com', '/maps/geo?q=#{CGI.escape(address_str)}&output=xml&key=#{key}'
res = Hpricot.XML(open("http://maps.google.com/maps/geo?q=#{CGI.escape(address_str)}&output=xml&key=#{key}"))
puts res
puts
puts
cl = RFuzz::HttpClient.new("maps.google.com", 80, :query=>"q=#{CGI.escape(address_str)}&output=xml&key=#{key}")
#cl = RFuzz::HttpClient.new("maps.google.com", 80)
puts cl
#res =  cl.get("/maps/geo?q=#{CGI.escape(address_str)}&output=xml&key=#{key}").http_body
res = cl.get("/maps")
puts 
puts res
puts res.class
doc = Hpricot.XML(res)
puts
puts doc
puts doc.class


# ---------- THIS WORKS ---------------
# #cl page
# pages = [ 707280718, 707121866]
# pages.each do |page|
#   puts page
#   doc = Hpricot(open("http://boulder.craigslist.org/apa/#{page}.html"))
#   doc.search("table") do |table|
#     puts table
#     puts "found it" if table.to_s.match(/images.craigslist.org/)
# 
#   end
# end

