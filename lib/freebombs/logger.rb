
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; module Logger

  def timestamp
    Time.new.strftime( "%Y-%m-%d %H:%M:%S" )
  end

  def log( message )
    puts "#{timestamp} -- #{message}"
  end

  def error( message )
    log "Error: "+message
  end

end; end

