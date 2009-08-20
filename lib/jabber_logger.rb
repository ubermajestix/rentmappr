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
    @client.allow_tls = true
    to = JID::new("tyler.a.montgomery@gmail.com")
    subject = "Logging Output"
    body = message.to_s
    m = Message::new(to, body)#.set_type(:normal).set_id('1').set_subject(subject)
    puts m.inspect
    @client.send m
  end
  
end