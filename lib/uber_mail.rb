require 'net/smtp'
require 'smtp_tls'
module UberMail
  def self.send(message)
    puts "trying to sendmail!"
    Net::SMTP.start( 'smtp.gmail.com' , 
                     587, 
                     'rentmappr.com', 
                     "logger@rentmappr.com"          , 
                     "logger1!", 
                     'plain' ){ |smtp| smtp.send_message(message,"logger@rentmappr.com", ["tyler.a.montgomery@gmail.com", "logger@rentmappr.com"])}
  end
end