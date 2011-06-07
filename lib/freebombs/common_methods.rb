
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; module CommonMethods

  def opt_key; :undefined; end

  def db
    @opt[:db_handler]
  end
  
  def setup
    puts "Undefined setup!"
  end
  
  def initialize( opt )
    opt[ opt_key ] = self
    @opt = opt
    setup
  end

end; end