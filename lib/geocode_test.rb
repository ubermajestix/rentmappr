addresses = %w{+Garden+Home+Road+at+Olseon+Road+Portland+Or+US
1+block+E+of+82nd+at+3+bolcks+S.+of+Holgate+Portland+Or+US
12310+SW+Thornwood+Dr.+at+Aspen+Ridge+&+Bull+Mt.+Rd.+Tigard+OR+US
1346+West+hist.+Col+river+Dr+troutdale+or+US
135+Wilford+Rd+at+Streeter+Silverlake+WA+US
135th+ave+at+59th+st+Vancouver+WA+US
16302+Jada+Way+at+Holcomb+Blvd+Oregon+City+OR+US
16th+St.+at+190th+Vancouver+wa+US
16th+St.+at+190th+Vancouver+wa+US
17174+W.+Villa+Rd.+at+SW+Carlson+Sherwood+OR+US
19145+Oak+Ave.+at+Bornstedt+Rd.+Sandy+OR+US
191st+at+34th+Vancouver/Camas+WA+US
20053+S.+Heider+Dr.+at+Glen+Oak+Oregon+City+OR+US
2029+NE+80+th+at+N+E+82+nd+Ave+Portland+OR+US
207th+at+223rd+Fairview+OR+US
208th+Terrace+at+205th+Beaverton+OR+US
209th+Pl+SW+at+Larchway+Lynnwood+WA+US
210+S.+State+St+at+McVey+Lake+Oswego+OR+US
210+S.+State+St+at+McVey+Lake+Oswego+OR+US
214th+at+TVH+Aloha+OR+US
2215+NE+139th+Cr.+at+20th+Ave+Vancouver+WA+US}

@matches = 0
for address in addresses
  
  if address.match(/\+at\+/)
    if address.match(/([0-9])([\+])([A-Za-z])/)
      @matches +=1 
      street = address[0...address.index("+at+")]
      puts address
      #puts street
      csc = address.split("+")
      csc = csc[csc.length-3...csc.length]
      address = street + "+" + csc.join("+")
      puts address.gsub(".","")
    end
  end
  
end
puts "#{@matches}/#{addresses.length}"
