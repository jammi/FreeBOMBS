
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

require 'rubygems'
require 'yaml'
require 'bluecloth'

require 'freebombs/logger'
require 'freebombs/locale_strings'
require 'freebombs/db_handler'
require 'freebombs/suppliers'
require 'freebombs/components'
require 'freebombs/configurations'

module FreeBOMBS
  def self.read_config( conf_path=false )
    unless conf_path
      base_path = File.split( File.split( File.expand_path( __FILE__ ) ).first ).first
      conf_path = File.expand_path( 'conf/config.yaml', base_path )
    end
    YAML.load_file( conf_path )
  end
  def self.read_strings( strings_path=false )
    unless strings_path
      base_path = File.split( File.split( File.expand_path( __FILE__ ) ).first ).first
      strings_path = File.expand_path( 'rsrc/strings.yaml', base_path )
    end
    read_config( strings_path )
  end
  def self.init( conf=false, strings=false )
    conf = read_config['freebombs'] unless conf
    strings = read_strings unless strings
    opt = {
      :db_path => conf['db_path'],
      :strings => LocaleStrings.new( strings ),
      :conf    => LocaleStrings.new( conf )
    }
    opt[:db_handler] = DBHandler.new( opt )
    Suppliers.new( opt )
    Components.new( opt )
    Configurations.new( opt )
  end
  def self.cli
    init
    puts "CLI mode not implemented yet!"
  end
end