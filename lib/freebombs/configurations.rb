
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class Configurations
  def setup
  end
  def initialize( opt )
    opt[:configurations] = self
    @opt = opt
    setup
  end
end; end

