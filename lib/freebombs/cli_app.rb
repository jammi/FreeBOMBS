
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

require 'highline'
module FreeBOMBS; class CLIApp
  def configurations; @opt[:configurations]; end
  def calculator; @calculator; end
  def format_currency( price, decimal_places=3 )
    deci_round = 10**decimal_places
    number_adjusted = (price*deci_round).round/deci_round.to_f
    ( number_whole, number_deci ) = number_adjusted.to_s.split('.')
    number_deci += '0' * ( decimal_places-number_deci.length )
    number_string = number_whole+'.'+number_deci
    if @currency == :EUR
      number_string += ' EUR'
    elsif @currency == :USD
      number_string = '$'+number_string
    end
  end
  def bom
    puts
    puts " Bill of materials for #{@multi} configuration(s) of #{configurations.title}:"
    puts
    puts " Component ID                      |  Units  |  Unit price  |      Price"
    puts " ----------------------------------+---------+--------------+----------- "
    price_list = calculator.calculate_price( @data, @supplier, @multi, @currency )
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
    puts " ----------------------------------+---------+--------------+----------- "
    sum_rjust = format_currency( price_sum, 2 ).rjust( 11 )
    puts " SUM:                                                       |#{sum_rjust}"
    puts
  end
  def setup
    @data = configurations.export
    @calculator = Calculator.new( @opt )
    @supplier = :digikey
    @currency = :EUR
    @multi = 1
    bom
  end
  def initialize( opt )
    @opt = opt
    setup
  end
end; end

