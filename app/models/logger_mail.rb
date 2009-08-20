class LoggerMail < ActionMailer::Base
  
  def mail(message)
    recipients "tyler.a.montgomery@gmail.com"
    from  "logger@rentmappr.com"
    subject "rentmappr logger"
    body :message=>message
    content_type "text/html"
  end

end
