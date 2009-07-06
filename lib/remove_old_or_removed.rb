#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'activerecord'
require 'rfuzz/client'
require 'net/http'
require 'logger'

ActiveRecord::Base.establish_connection(
                                        :adapter  => "mysql", 
                                        :host     => "localhost",
                                        :username => "root",
                                        :password => "",
                                        :database => "bldrcl", 
					:pool => 20, :wait_timeout => 15)

@start_run = Time.now

class House < ActiveRecord::Base
  validates_uniqueness_of :href, :address
  validates_presence_of :title, :href, :address
 # validates_length_of :address, :minimum=>10
end

class MapArea < ActiveRecord::Base
  has_many :houses
end

class GeoLoc
  attr_accessor :lat
  attr_accessor :lng
  attr_accessor :success
end


# script needs to check for "Posting Deleted by Author for existing geocoded houses"
# - alert users to fact that CL posting removed?
# script needs to remove all houses older than area's valid timeframe unless saved by users
