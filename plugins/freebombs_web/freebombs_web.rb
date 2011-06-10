
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

require 'freebombs'

class FreeBOMBS_App < GUIPlugin
  def configurations; @opt[:configurations]; end
  def sections; @opt[:sections]; end
  def components; @opt[:components]; end
  def suppliers; @opt[:suppliers]; end
  def calculator; @calculator; end

  def format_currency( price, decimal_places=3 )
    deci_round = 10**decimal_places
    number_adjusted = (price*deci_round).round/deci_round.to_f
    ( number_whole, number_deci ) = number_adjusted.to_s.split('.')
    number_deci += '0' * ( decimal_places-number_deci.length )
    number_string = number_whole+'.'+number_deci
    if @data[:currency] == :EUR
      number_string += ' &euro;'
    elsif @data[:currency] == :USD
      number_string = '$'+number_string
    end
    number_string
  end
  def open
    super
    @conf = RSence.config['freebombs']
    @strings = YAML.load_file( @conf['locale_strings'] )
    @opt = FreeBOMBS.init_web( @conf['db_name'], @conf, @strings )
    @currencies_list = @strings['currencies']
  end
  def suppliers_list( msg )
    arr = []
    user_data( msg )[:suppliers].each do |supplier_id|
      arr.push( [ supplier_id.to_s, suppliers[supplier_id].title ] )
    end
    arr
  end
  def gui_params( msg )
    params = super
    params[:strings] = @strings
    params[:app_title] = 'FreeBOMBS'
    params[:lists] = {
      :suppliers => suppliers_list( msg ),
      :currencies => @currencies_list
    }
    params
  end
  def user_data( msg )
    msg.user_info[:freebombs]
  end
  def init_ses( msg )
    msg.user_info = {} unless msg.user_info.class == Hash
    msg.user_info[:freebombs] = configurations.export
    super
  end

  def recalculate( msg )

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

