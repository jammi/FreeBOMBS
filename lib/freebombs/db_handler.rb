
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class DBHandler
  
  def dbs
    [ 'component_types', 'components', 'configurations', 'suppliers' ]
  end

  def error( message )
    puts
    puts "Error: "+message
    puts
    exit
  end

  def yaml_path( name )
    File.expand_path( name+'.yaml', @db_path )
  end

  def files_exist?
    dbs.each do |name|
      error "Missing database file: #{file}.yaml" unless File.exist? yaml_path( name )
    end
  end

  def read_data
    @db = {}
    dbs.each do |name|
      db_path = yaml_path( name )
      puts "reading db: #{db_path}"
      # read backtrace for yaml syntax errors, if encountered
      @db[name] = YAML.load_file( db_path )
    end
  end

  def suppliers
    @db['suppliers']
  end

  def components
    @db['components']
  end

  def valid_url?( url )
    ( url.start_with?('http://') or url.start_with?('https://') ) and url.length > 10
  end

  def initialize( db_path )
    @db_path = db_path
    files_exist?
    read_data
  end

end; end
