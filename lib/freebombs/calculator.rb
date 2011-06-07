
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class Calculator

  include Logger

  def suppliers; @opt[:suppliers]; end
  def components; @opt[:components]; end

  def count_of( data, multi, outp={} )
    data.each do | checked, amount, component_id |
      next unless checked
      next if amount == 0
      puts "nil: #{component_id.inspect}, data: #{data.inspect}" if amount.nil?
      multi_amount = multi*amount
      outp[ component_id ] = 0 unless outp.has_key? component_id
      outp[ component_id ] += multi_amount
    end
    outp
  end

  def calculate_price( data, multi=1 )
    supplier_id = data[:supplier]
    currency = data[:currency]
    unless @opt[:suppliers].supplier_ids.include? supplier_id
      error "Configurations#calculate_price: unknown supplier: #{supplier.inspect}"
      return
    end
    count_list = count_of( data[:components], multi )
    data[:sections].each do |section|
      next unless section[:checked]
      next if section[:components].empty?
      next if section[:value] == 0
      s_multi = multi*section[:value]
      count_of( section[:components], s_multi, count_list )
    end
    # currency = @opt[:suppliers].supplier(supplier_id).currency
    price_sum = 0.0
    price_list = {}
    count_list.each do |component_id, count|
      component = @opt[:components][component_id]
      price = component.price( supplier_id ).to_currency( currency )
      price_list[component_id] = [ count, price, count*price ]
    end
    # require 'pp'; pp price_list
    price_list
  end

  def initialize( opt )
    @opt = opt
  end

end; end

