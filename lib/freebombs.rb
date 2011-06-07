
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

$verbose = false
$md_to_html = true
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
  def self.init( db_name=false, conf=false, strings=false )
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



    exported = opt[:configurations].export
    puts " Price list:"
    puts " #{'Component ID'.ljust(32)}  |   Price    "
    price_list = opt[:configurations].calculate_price( exported, :digikey, 1, :EUR )
    price_sum = 0
    price_list.each do |component_id, price |
      price_sum += price
      puts " #{component_id.to_s.ljust(32)}  |  #{((price*100).round/100.0).to_s.rjust(6)} EUR"
    end
      puts " #{'SUM:'.ljust(32)}  |  #{((price_sum*100).round/100.0).to_s.rjust(6)} EUR"



    opt
  end
  def self.cli_usage
    puts <<END
Usage: #{$0} [database_name]
END
  end
  def self.cli
    $md_to_html = false
    if ARGV.length == 0
      init
    elsif ARGV.length == 1
      db_name = ARGV.first
      init db_name
    else
      cli_usage
    end
    puts "CLI mode not implemented yet!"
  end
end

