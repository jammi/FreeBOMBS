
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
    puts " Total:                                                     |#{sum_rjust}"
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

  def puts_sections
    puts
    puts "Available configuration options:"
    puts "--------------------------------"
    sections_spec = @data[:sections]
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
    puts_sections
    puts
  end

  def get_section( section_id )
    @data[:sections].each do |section_spec|
      return section_spec if section_spec[:id] == section_id
    end
  end

  def toggle_section_on( section_spec )
    toggle_sections_off( section_spec[:excludes] )
    section_spec[:checked] = true
  end

  def toggle_sections_off( section_ids )
    @data[:sections].each do |section_spec|
      section_spec[:checked] = false if section_ids.include? section_spec[:id]
    end
  end

  def toggle_section_off( section_spec )
    section_spec[:checked] = false
  end

  def toggle_section( section_id )
    section_spec = get_section( section_id )
    if section_spec[:checked] == true
      toggle_section_off( section_spec )
    else
      toggle_section_on( section_spec )
    end
  end

  def toggle_sections_menu
    choose do |menu|
      @data[:sections].each do |section_spec|
        if section_spec[:checked]
          checkbox = "[X]"
        else
          checkbox = "[ ]"
        end
        section_title = sections[ section_spec[:id] ].title
        menu.choice( "#{checkbox} (#{section_spec[:id]}): #{section_title}" ) do |menu_str|
          section_id = (menu_str.gsub(/(\[[X\ ]\]) \((.*?)\)\: (.*?)$/) { $2 }).to_sym
          toggle_section( section_id )
        end
      end
      menu.choice( "Return to configuration sections menu" ) do
        @return_sections = true
      end
      menu.choice( "Return to main menu" ) do
        @return_sections = true
        @return = true
      end
      menu.prompt = "Toggle section>"
    end
  end

  def view_section_details( section_id )
    section_spec = get_section( section_id )
    section = sections[ section_id ]
    title = section.title
    description = section.description
    puts
    puts "Details of section '#{title}'"
    puts
    puts title
    puts '-' * title.length
    puts description
    puts
    puts "Enabled: #{section_spec[:checked]}"
    puts "Amount:  #{section_spec[:value]} (min: #{section_spec[:min]}, max: #{section_spec[:max]})"
    puts
    unless section_spec[:components].empty?
      puts "Components:"
      puts_components( section_spec[:components] )
    end
  end

  def set_section_value
    section_spec = get_section( @selected_section_id )
    section_spec[:value] = ask( "Set the amount of this configuration (min #{section_spec[:min]}, max #{section_spec[:max]}, currently #{section_spec[:value]}): ", Integer )
  end

  def section_details_menu( section_id )
    view_section_details( section_id )
    puts
    choose do |menu|
      section_spec = get_section( section_id )
      @selected_section_id = section_id
      menu.choice( "Change amount (currently #{section_spec[:value]})" ) do
        section_spec = get_section( @selected_section_id )
        set_section_value
        set_section_value while section_spec[:value] < section_spec[:min] or section_spec[:value] > section_spec[:max] 
      end
      menu.choice( "Return to section details menu" ) do
        @return_section_details = true
      end
      menu.choice( "Return to configuration sections menu" ) do
        @return_section_details = true
        @return_sections = true
      end
      menu.choice( "Return to main menu" ) do
        @return_section_details = true
        @return_sections = true
        @return = true
      end
      menu.prompt = "Section details>"
    end
  end

  def view_section_details_menu
    puts
    puts "Choose the configuration section to view/edit:"
    puts
    choose do |menu|
      @data[:sections].each do |section_spec|
        section_title = sections[ section_spec[:id] ].title
        menu.choice( "(#{section_spec[:id]}): #{section_title}" ) do |menu_str|
          section_id = (menu_str.gsub(/\((.*?)\)\: (.*?)$/) { $1 }).to_sym
          @return_section_details = false
          section_details_menu( section_id ) until @return_section_details
        end
      end
      menu.choice( "Return to configuration sections menu" ) do
        @return_sections = true
      end
      menu.choice( "Return to main menu" ) do
        @return_sections = true
        @return = true
      end
      menu.prompt = "Toggle section>"
    end
  end

  def set_multi_menu
    @multi = ask( "Enter amount of configurations to order (min 1, currently #{@multi}): ", Integer )
  end

  def settings_menu
    choose do |menu|
      menu.choice( "Set supplier (currently #{supplier_title( @data[:supplier] )})" ) do
        set_supplier_menu
      end
      menu.choice( "Set currency (currently #{@data[:currency]})" ) do
        set_currency_menu
      end
      menu.choice( "Set amount of configurations to order (currently #{@multi})" ) do
        set_multi_menu
        set_multi_menu while @multi < 1
      end
      menu.choice( "Return to main menu" ) do
        @return = true
      end
      menu.prompt = "Settings>"
    end
  end

  def sections_menu
    puts_sections
    puts
    choose do |menu|
      menu.choice( "Toggle sections" ) do
        @return_sections = false; toggle_sections_menu until @return_sections
      end
      menu.choice( "View section details" ) do
        @return_sections = false; view_section_details_menu until @return_sections
      end
      menu.choice( "Return to main menu" ) do
        @return = true
      end
      menu.prompt = "Configuration sections>"
    end
  end

  def main_menu
    puts_main
    choose do |menu|
      menu.choice( "View baseline components" ) do
        puts_baseline_config
      end
      menu.choice( "Configuration sections menu" ) do 
        @return = false; sections_menu until @return
      end
      menu.choice( "View BOM" ) do
        bom
      end
      menu.choice( "Settings menu" ) do
        @return = false; settings_menu until @return
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
    main_menu until false
  end
end; end

