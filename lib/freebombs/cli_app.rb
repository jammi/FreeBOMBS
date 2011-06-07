
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

require 'highline/import'

module FreeBOMBS; class CLIApp
  
  def configurations; @opt[:configurations]; end
  def sections; @opt[:sections]; end
  def components; @opt[:components]; end
  def suppliers; @opt[:suppliers]; end
  
  def calculator; @calculator; end
  
  # def puts( str="\n" )
  #   say str
  # end

  def format_currency( price, decimal_places=3 )
    deci_round = 10**decimal_places
    number_adjusted = (price*deci_round).round/deci_round.to_f
    ( number_whole, number_deci ) = number_adjusted.to_s.split('.')
    number_deci += '0' * ( decimal_places-number_deci.length )
    number_string = number_whole+'.'+number_deci
    if @data[:currency] == :EUR
      number_string += ' EUR'
    elsif @data[:currency] == :USD
      number_string = '$'+number_string
    end
  end
  
  def component_list_header
    puts " Component ID                      |  Units  |  Unit price  |      Price"
    puts " ----------------------------------+---------+--------------+----------- "
  end

  def component_list_footer
    puts " ----------------------------------+---------+--------------+----------- "
  end

  def bom
    puts
    puts " Bill of materials for #{@multi} configuration(s) of #{configurations.title}:"
    puts
    component_list_header
    price_list = calculator.calculate_price( @data, @multi )
    price_sum = 0
    price_list.each do |component_id, price_data |
      ( units, unit_price, price ) = price_data
      price_sum += price
      component_ljust = component_id.to_s.ljust(32)
      units_rjust = units.to_s.rjust(5)
      unit_price_rjust = format_currency(unit_price).rjust( 10 )
      price_rjust = format_currency(price,2).rjust( 10 )
      puts " #{component_ljust}  |  #{units_rjust}  |  #{unit_price_rjust}  | #{price_rjust}"
    end
    component_list_footer
    sum_rjust = format_currency( price_sum, 2 ).rjust( 11 )
    puts " SUM:                                                       |#{sum_rjust}"
    puts
  end
  
  def setup
    @data = configurations.export
    @calculator = Calculator.new( @opt )
    @multi = 1
  end
  
  def puts_components( component_specs )
    puts "    |  # |  Component ID        |  Title                          "
    puts "    +----+----------------------+-------------------------------- "
    component_specs.each do |component_spec|
      ( enabled, units, component_id ) = component_spec
      if enabled
        checkbox = "[X]"
      else
        checkbox = "[ ]"
      end
      units_rjust = units.to_s.rjust(3)
      id_s = component_id.to_s
      id_s = id_s[0..16]+'...' if id_s.length >= 20
      id_ljust = id_s.ljust( 20 )
      title = components[component_id].title
      title = title[0..26]+'...' if title.length >= 30
      title_ljust = title.ljust( 30 )
      puts "#{checkbox} |#{units_rjust} |  #{id_ljust}|  #{title_ljust}"
    end
    puts "    +----+----------------------+-------------------------------- "
  end

  def puts_section( section_spec )
    if section_spec[:checked]
      checkbox = "[X]"
    else
      checkbox = "[ ]"
    end
    section_title = sections[ section_spec[:id] ].title
    puts "#{checkbox} #{section_title}"
  end

  def puts_sections( section_specs )
    puts
    puts "Available configuration options:"
    puts "--------------------------------"

    @data[:sections].each do |section_spec|
      puts_section section_spec
    end
  end

  def puts_baseline_config
    puts
    puts "Baseline configuration:"
    puts "-----------------------"
    puts
    puts_components( @data[:components] )
    puts
  end

  def supplier_title( supplier_id )
    suppliers[ supplier_id ].title
  end

  def set_supplier_menu
    choose do |menu|
      @data[:suppliers].each do |supplier_id|
        menu.choice( supplier_id ) do |supplier_id|
          puts "Setting supplier to #{supplier_title(supplier_id)}"
          @data[:supplier] = supplier_id
        end
      end
      menu.prompt = "Set supplier>"
    end
  end

  def set_currency_menu
    choose do |menu|
      [:EUR,:USD].each do |currency|
        menu.choice( currency ) do |currency|
          puts "Setting currency to #{currency}"
          @data[:currency] = currency
        end
      end
      menu.prompt = "Set currency>"
    end
  end

  def puts_main
    puts
    puts configurations.title
    puts '-'*configurations.title.length
    puts configurations.description
    puts
    # puts_baseline_config
    puts_sections( @data[:sections] )
    puts
  end

  def main_menu
    choose do |menu|
      menu.choice( "View overview" ) do
        puts_main
      end
      menu.choice( "View baseline components" ) do
        puts_baseline_config
      end
      menu.choice( "View BOM" ) do
        bom
      end
      menu.choice( "Set supplier (currently #{supplier_title( @data[:supplier] )})" ) do
        set_supplier_menu
      end
      menu.choice( "Set currency (currently #{@data[:currency]})" ) do
        set_currency_menu
      end
      menu.choice( "Exit" ) do
        exit
      end
      menu.prompt = ">"
    end
  end
  
  def initialize( opt )
    @opt = opt
    setup
    puts_main
    main_menu until false
  end
end; end

