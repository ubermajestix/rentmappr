require 'xmpp4r/client'
module JabberLogger
  include Jabber
  
  def self.send(message)
    # Jabber::debug = true 
    jid = JID::new('logger@rentmappr.com')
    password = 'logger1!'
    @client = Client::new(jid)
    @client.connect('talk.google.com', 5222)
    @client.auth(password)
    # @client.allow_tls = true
    @client.send(Jabber::Presence.new.set_status("ready for logging say what?"))
    to = JID::new("tyler.a.montgomery@gmail.com")
    subject = "Logging Output"
    body = message.to_s
    m = Message::new(to, body).set_type(:chat).set_id('1').set_subject(subject)
    puts m.inspect
    @client.send m
  end
  
  def self.send_error(e)
    self.send("#{e.class}\n\n#{e.message}\n\n#{e.backtrace.first}")
  end
  
end
