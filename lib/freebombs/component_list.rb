
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class ComponentList
  def components; @opt[:components]; end
  def setup( component_specs )
    @component_order = []
    @component_by_id = {}
    @component_amount_by_id = {}
    component_specs.each do |component_spec|
      if component_spec.class == Array
        amount = component_spec.first
        component_id = component_spec[1].to_sym
      else
        amount = 1
        component_id = component_spec.to_sym
      end
      component = components[component_id]
      @component_order.push( component_id )
      @component_by_id[ component_id ] = component
      @component_amount_by_id[ component_id ] = amount
    end
  end
  def initialize( opt, component_specs )
    @opt = opt
    setup( component_specs )
  end
end; end

