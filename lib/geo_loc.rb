class GeoLoc
  def initialize
    @success = false
  end
  attr_accessor :lat
  attr_accessor :lng
  attr_accessor :success
  attr_accessor :accuracy
end