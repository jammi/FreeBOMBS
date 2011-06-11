
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

require 'freebombs'

class FreeBOMBS_App < GUIPlugin
  def configurations; @opt[:configurations]; end
  def sections; @opt[:sections]; end
  def components; @opt[:components]; end
  def suppliers; @opt[:suppliers]; end
  def calculator; @calculator; end

  def open
    super
    @conf = RSence.config['freebombs']
    @strings = YAML.load_file( @conf['locale_strings'] )
    @opt = FreeBOMBS.init_web( @conf['db_name'], @conf, @strings )
    @currencies_list = @strings['currencies']
    @calculator = FreeBOMBS::Calculator.new( @opt )
  end
  def suppliers_list( msg )
    arr = []
    user_data( msg )[:suppliers].each do |supplier_id|
      arr.push( [ supplier_id.to_s, suppliers[supplier_id].title ] )
    end
    arr
  end
  def components_client_spec( msg, sd_components )
    arr = []
    sd_components.each_with_index do |sd_component, i|
      arr.push({
        'id' => sd_component[:id].to_s,
        'count' => sd_component[:count].value_id,
        'enabled' => sd_component[:enabled].value_id
      })
    end
    arr
  end
  def presets_client_spec( presets )
    arr = []
    presets.each do | preset |
      arr.push( [ preset[:value], preset[:title] ] )
    end
    arr
  end
  def config_data_client_spec( msg )
    ud = user_data( msg )
    ses = get_ses( msg )
    hash = {}
    hash['title'] = configurations.title
    hash['description'] = configurations.description
    hash['components'] = components_client_spec( msg, ses[:components] )
    hash['sections'] = []
    ud[:sections].each_with_index do |section_spec, i|
      section_id = section_spec[:id]
      section = sections[section_id]
      sd_section = ses[:sections][i]
      presets = presets_client_spec( section_spec[:presets] )
      presets.unshift( [nil,@strings['default_preset']] ) unless presets.empty?
      hash['sections'].push({
        'title' => section.title,
        'description' => section.description,
        'min' => section_spec[:min],
        'max' => section_spec[:max],
        'enabled' => sd_section[:enabled].value_id,
        'count'   => sd_section[:count].value_id,
        'components' => components_client_spec( msg, sd_section[:components] ),
        'presets' => presets
      })
    end
    hash
  end
  def gui_params( msg )
    params = super
    params[:strings] = @strings
    params[:app_title] = 'FreeBOMBS'
    params[:configuration_data] = config_data_client_spec( msg )
    params[:lists] = {
      :suppliers => suppliers_list( msg ),
      :currencies => @currencies_list
    }
    params
  end
  def user_data( msg )
    msg.user_info[:freebombs]
  end
  def set_component_enabled( msg, value )
    metadata = value.meta[:spec]
    data = value.data
    orig = metadata[0]
    if [ true, false ].include? data and data != orig
      metadata[0] = data
      recalculate( msg )
    else
      value.set( msg, orig )
    end
    true
  end
  def set_component_count( msg, value )
    metadata = value.meta[:spec]
    data = value.data
    orig = metadata[1]
    if data.class == Fixnum and data >= 0 and data != orig
      metadata[1] = data
      recalculate( msg )
    else
      value.set( msg, orig )
    end
    true
  end
  def disable_sections( msg, section_ids )
    ud_sections = user_data( msg )[:sections]
    sd_sections = get_ses( msg, :sections )
    ud_sections.each_with_index do |section_spec,i|
      if section_ids.include? section_spec[:id]
        section_spec[:checked] = false
        sd_sections[i][:enabled].set( msg, false )
      end
    end
  end
  def set_section_enabled( msg, value )
    metadata = value.meta[:spec]
    data = value.data
    orig = metadata[:enabled]
    if [ true, false ].include? data and data != orig
      metadata[:checked] = data
      puts metadata.inspect
      puts metadata[:excludes].inspect
      unless metadata[:excludes].empty?
        disable_sections( msg, metadata[:excludes] )
      end
      recalculate( msg )
    else
      value.set( msg, orig )
    end
    true
  end
  def set_section_count( msg, value )
    metadata = value.meta[:spec]
    data = value.data
    min  = metadata[:min]
    max  = metadata[:max]
    orig = metadata[:value]
    if data.class == Fixnum and data >= min and data <= max and data != orig
      metadata[:value] = data
      recalculate( msg )
    else
      value.set( msg, orig )
    end
    true
  end
  def init_dynamic_component_values( msg, source, container )
    source.each_with_index do |component_spec, i|
      metadata = { :spec => component_spec }
      component_values = {
        :id      => component_spec[2],
        :enabled => HValue.new( msg, component_spec[0], metadata ),
        :count   => HValue.new( msg, component_spec[1], metadata )
      }
      component_values[:enabled].bind( name_with_manager_s, :set_component_enabled )
      component_values[:count  ].bind( name_with_manager_s, :set_component_count   )
      container.push( component_values )
    end
  end
  def init_dynamic_section_values( msg, source, container )
    source.each_with_index do |section_spec, i|
      metadata = { :spec => section_spec }
      section_values = {
        :id => section_spec[:id],
        :enabled => HValue.new( msg, section_spec[:checked], metadata ),
        :count   => HValue.new( msg, section_spec[:value  ], metadata )
      }
      section_values[:enabled].bind( name_with_manager_s, :set_section_enabled )
      section_values[:count  ].bind( name_with_manager_s, :set_section_count   )
      section_values[:components] = []
      unless section_spec[:components].empty?
        init_dynamic_component_values( msg, section_spec[:components], section_values[:components] )
      end
      container.push( section_values )
    end
  end
  def init_dynamic_values( msg )
    ud = user_data( msg )
    ses = get_ses( msg )
    ses[:components] = []
    init_dynamic_component_values( msg, ud[:components], ses[:components] )
    ses[:sections] = []
    init_dynamic_section_values( msg, ud[:sections], ses[:sections] )
  end
  def init_ses( msg )
    msg.user_info = {} unless msg.user_info.class == Hash
    msg.user_info[:freebombs] = configurations.export
    super
    init_dynamic_values( msg )
    recalculate( msg )
  end

  def format_currency( price, decimal_places=3, currency=:EUR )
    deci_round = 10**decimal_places
    number_adjusted = (price*deci_round).round/deci_round.to_f
    ( number_whole, number_deci ) = number_adjusted.to_s.split('.')
    number_deci += '0' * ( decimal_places-number_deci.length )
    number_string = number_whole+'.'+number_deci
    if currency == :EUR
      number_string += ' EUR'
    elsif currency == :USD
      number_string = '$'+number_string
    end
    number_string
  end
  def recalculate( msg )
    arr = []
    data = user_data( msg )
    multi = get_ses( msg, :multi ).data
    arr.push ''
    arr.push " Bill of materials for #{multi} configuration(s) of #{configurations.title}:"
    arr.push ''
    arr.push  " Component ID                      |  Units  |  Unit price  |      Price"
    arr.push " ----------------------------------+---------+--------------+----------- "
    price_list = calculator.calculate_price( data, multi )
    price_sum = 0
    price_list.each do |component_id, price_data |
      ( units, unit_price, price ) = price_data
      price_sum += price
      component_ljust = component_id.to_s.ljust(32)
      units_rjust = units.to_s.rjust(5)
      unit_price_rjust = format_currency(unit_price, 3, data[:currency]).rjust( 10 )
      price_rjust = format_currency(price,2, data[:currency]).rjust( 10 )
      arr.push " #{component_ljust}  |  #{units_rjust}  |  #{unit_price_rjust}  | #{price_rjust}"
    end
    arr.push " ----------------------------------+---------+--------------+----------- "
    sum_rjust = format_currency( price_sum, 2, data[:currency] ).rjust( 11 )
    arr.push " Total:                                                     |#{sum_rjust}"
    arr.push
    str = arr.join('<br>')
    get_ses( msg, :bom ).set( msg, str )    
  end

  def get_supplier( msg )
    user_data( msg )[:supplier]
  end
  def set_supplier( msg, value )
    ud = user_data( msg )
    ud[:supplier] = value.data.to_sym if ud[:suppliers].include? value.data.to_sym
    recalculate( msg )
    puts "supplier set to: #{value.data}"
    true
  end
  
  def set_multi( msg, value )
    data = value.data
    data = 1 unless data.class == Fixnum
    data = 1 if data < 1
    data = 100 if data > 100
    value.set( msg, data ) unless value.data == data
    recalculate( msg )
    puts "multiplier set to: #{value.data}"
    true
  end
  
  def get_currency( msg )
    user_data( msg )[:currency].to_s
  end
  def set_currency( msg, value )
    unless ['EUR', 'USD'].include? value.data
      value.set( msg, 'EUR' )
    end
    user_data( msg )[:currency] = value.data.to_sym
    recalculate( msg )
    puts "currency set to: #{value.data}"
    true
  end
end

