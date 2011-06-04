#!/usr/bin/env ruby

# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

require 'rubygems'
require 'yaml'

base_path = File.split( File.split( File.expand_path( __FILE__ ) ).first ).first
$LOAD_PATH << File.join( base_path, 'lib' )

require 'freebombs/db_handler'

class CheckDBSanity < FreeBOMBS::DBHandler

  def check_suppliers
    mandatory_keys = [ 'title', 'homepage' ]
    suppliers.each_key do |name|
      puts "Checking supplier: #{name}"
      supplier = suppliers[name]
      mandatory_keys.each do |key|
        error "Missing #{key} for supplier #{name}" unless supplier.has_key? key
      end
    end
  end

  def validate_supply( supply_spec )
    unless supply_spec['part'].class == String
      error "Invalid part specification: #{supply_spec['part'].inspect}"
    end
    unless supply_spec['price'].class == Array
      error "Invalid price specification: #{supply_spec['price'].inspect}"
    end
    unless supply_spec['price'].length == 2
      error "Invalid price specification length: #{supply_spec['price'].inspect}"
    end
    price_num = supply_spec['price'][0]
    unless [ Float, Fixnum ].include? price_num.class
      error "Invalid price: #{price_num.inspect}"
    end
    price_currency = supply_spec['price'][1]
    unless [ 'USD', 'EUR' ].include? price_currency
      error "Invalid currency: #{price_currency.inspect}"
    end
  end

  def check_components
    # the only mandatory key is title, the rest depends on choices:
    # if the component is obsolete:
    #  - it must either have a valid replacement or no replacement at all!
    # otherwise:
    #  - the item must have a valid supplier specification, including part-number and price
    #    - if any supplier is not defined, issue a warning
    #  - the component must have a datasheet or a description field defined
    mandatory_keys = [ 'title' ]
    components.each_key do |mfg_id|
      puts "Checking component: #{mfg_id}"
      component = components[mfg_id]
      mandatory_keys.each do |key|
        error "Component #{mfg_id} is missing #{key}" unless component.has_key? key
      end
      if component['obsolete']
        if component.has_key? 'replacement'
          replacement = component['replacement']
          if components.has_key? replacement
            puts "..obsolete, replacement: #{replacement}"
            next
          else
            puts component.inspect
            error "Missing replacement component id: #{replacement.inspect}"
          end
        else
          puts "..obsolete, no replacement!"
        end
      else
        component_supply = component['suppliers']
        if component_supply.class != Hash
          error "Invalid component supply specification: #{component_supply}"
        end
        suppliers.each_key do |supplier_name|
          if component_supply.has_key? supplier_name
            validate_supply( component_supply[supplier_name] )
          else
            puts "..no supply information for supplier: #{supplier_name}"
          end
        end
        if component.has_key? 'datasheet'
          datasheet = component['datasheet']
          if not datasheet.class == String
            error "Invalid type of datasheet URL (datasheet): #{datasheet.inspect}"
          elsif not valid_url?( datasheet )
            error "Invalid format of datasheet URL (datasheet): #{datasheet.inspect}"
          end
        elsif not component.has_key? 'description'
          error "Datasheet URL (datasheet) is missing for component: #{mfg_id}"
        end
      end
    end
  end

  def initialize( db_path )
    super
    check_suppliers
    check_components
  end

end

test_db_path = File.join( base_path, 'dbs', 'freeems-puma-spin1' )
CheckDBSanity.new( test_db_path )
