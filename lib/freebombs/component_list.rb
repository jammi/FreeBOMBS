
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class ComponentList
  include Logger
  def components; @opt[:components]; end
  def empty?; @component_order.empty?; end
  def setup( component_specs )
    @component_order = []
    @component_by_id = {}
    @component_amount_by_id = {}
    return if component_specs.nil?
    component_specs.each do |component_spec|
      if component_spec.class == Array
        amount = component_spec.first
        component_id = component_spec[1].to_sym
      else
        amount = 1
        component_id = component_spec.to_sym
      end
      component = components[component_id]
      if component.obsolete?
        component = component.replacement
        log "ComponentList#setup: substituting #{component_id} with #{component.id}"
        component_id = component.id
      end
      @component_order.push( component_id )
      @component_by_id[ component_id ] = component
      @component_amount_by_id[ component_id ] = amount
    end
  end
  def initialize( opt, component_specs )
    @opt = opt
    setup( component_specs )
  end
  def export
    arr = []
    @component_order.each do |component_id|
      arr.push( [
        true,
        @component_amount_by_id[ component_id ],
        component_id
      ] )
    end
    arr
  end
end; end

