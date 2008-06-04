require "open-uri"
pages = %w( http://www.rubycentral.com
            http://www.awl.com
            http://www.pragmaticprogrammer.com
           )


threads = []
start = Time.now

for page in pages
  threads << Thread.new(page) { |page|


    h = open(page)
    puts "Fetching: #{page}"
    resp = h.status[0]
    puts "Got #{page}:  #{resp}"
  }
end

puts "took: #{Time.now - start}"
threads.each { |aThread|  aThread.join }