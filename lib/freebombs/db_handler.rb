
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class DBHandler
  
  include Logger

  def dbs
    [ 'component_types', 'components', 'configurations', 'suppliers' ]
  end

  def yaml_path( name )
    File.expand_path( name+'.yaml', @db_path )
  end

  def files_exist?
    dbs.each do |name|
      error "Missing database file: #{name}.yaml" unless File.exist? yaml_path( name )
    end
  end

  def read_data
    @db = {}
    dbs.each do |name|
      db_path = yaml_path( name )
      log "Reading db: #{db_path}"
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

  def configurations
    @db['configurations']
  end

  def test; end

  def initialize( opt )
    if opt.class == String
      @db_path = opt
    else
      @db_path = opt[:db_path]
    end
    files_exist?
    read_data
    test
  end

end; end
