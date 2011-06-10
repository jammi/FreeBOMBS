
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

require 'rubygems'
require 'yaml'
require 'bluecloth'

require 'freebombs/common_methods'
require 'freebombs/logger'
require 'freebombs/locale_strings'
require 'freebombs/db_handler'
require 'freebombs/suppliers'
require 'freebombs/components'
require 'freebombs/component_list'
require 'freebombs/config_section'
require 'freebombs/config_sections'
require 'freebombs/configurations'
require 'freebombs/calculator'

$verbose = false
$md_to_html = true
module FreeBOMBS
  def self.read_config( conf_path=nil )
    unless conf_path
      base_path = File.split( File.split( File.expand_path( __FILE__ ) ).first ).first
      conf_path = File.expand_path( 'conf/config.yaml', base_path )
    end
    YAML.load_file( conf_path )
  end
  def self.read_strings( strings_path=nil )
    unless strings_path
      base_path = File.split( File.split( File.expand_path( __FILE__ ) ).first ).first
      strings_path = File.expand_path( 'rsrc/strings.yaml', base_path )
    end
    read_config( strings_path )
  end
  def self.init( db_name=nil, conf=nil, strings=nil )
    conf = read_config['freebombs'] unless conf
    strings = read_strings unless strings
    if db_name
      db_path = File.expand_path( db_name, conf['dbs_path'] )
    else
      db_path = File.expand_path( conf['db_name'], conf['dbs_path'] )
    end
    opt = {
      :db_path => db_path,
      :strings => LocaleStrings.new( strings ),
      :conf    => LocaleStrings.new( conf )
    }
    opt[:db_handler] = DBHandler.new( opt )
    Suppliers.new( opt )
    Components.new( opt )
    Configurations.new( opt )
    opt
  end
  def self.cli_usage
    puts <<END
Usage: #{$0} [database_name]
END
  end
  def self.init_cli( db_name=false )
    opt = init( db_name )
    require 'freebombs/cli_app'
    CLIApp.new( opt )
  end
  def self.cli
    $md_to_html = false
    if ARGV.length == 0
      init_cli
    elsif ARGV.length == 1
      db_name = ARGV.first
      init_cli db_name
    else
      cli_usage
    end
  end
  def self.init_web( db_name, conf, strings )
    init( db_name, conf, strings )
  end
end

