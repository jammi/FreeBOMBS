
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class Components

  include CommonMethods
  def opt_key; :components; end

  class ComponentBase
    include LocaleMethods
    attr_reader :id, :title, :descr, :img, :datasheet
    def has_img?
      ( not @img.nil? )
    end
    def initialize( opt, id, spec )
      @opt = opt
      @components = opt[:components]
      @id = id
      @title = spec['title']
      @descr = ''
      if spec.has_key? 'description'
        @descr += md( spec['description'] )
      end
      if spec.has_key? 'datasheet'
        @datasheet = spec['datasheet']
      end
      @img = spec['img_src']
      if spec['replacement'].nil?
        @replacement_id = nil
      else
        @replacement_id = spec['replacement'].to_sym
      end
    end
    def has_replacement?
      ( not @replacement_id.nil? )
    end
    def replacement
      if has_replacement?
        component = @components[ @replacement_id ]
        component = component.replacement while component.obsolete? and component.has_replacement?
        return component
      end
    end
    def suppliers
      @opt[:suppliers]
    end
    def obsolete?; false; end
    def export_to_client
      { 'obsolete' => obsolete?,
        'replacement' => has_replacement? ? replacement.id : nil,
        'id' => id,
        'title' => title,
        'description' => descr,
        'img' => img,
        'datasheet' => datasheet
        # ,
        # 'supplier_ids' => component.export_supplier_ids
      }
    end
    def to_s; "#<Component #{@id.inspect}: @title=#{@title.inspect}>"; end
  end

  class ObsoleteComponent < ComponentBase
    def obsolete?; true; end
    def to_s; "#<ObsoleteComponent #{@id.inspect}: @title=#{@title.inspect}, @replacement_id=#{@replacement_id.inspect}>"; end
  end
  
  class Component < ComponentBase
    def has_supplier?( supplier_id )
      ( not @supply[ supplier_id ].nil? )
    end
    def price( supplier_id )
      return -1 unless has_supplier?( supplier_id )
      return @supply[ supplier_id ][:price]
    end
    def initialize( opt, id, spec )
      super
      @supply = {}
      suppliers.supplier_ids.each do |supplier_id|
        id_s = supplier_id.to_s
        if spec['suppliers'].has_key? id_s
          spec_supply = spec['suppliers'][id_s]
          @supply[ supplier_id ] = {
            :part => spec_supply[ 'part' ],
            :price => Price.new( spec_supply['price'] )
          }
        end
      end
    end
  end
  
  attr_accessor :components

  def suppliers
    @opt[:suppliers]
  end
  
  def []( component_id )
    component_id = component_id.to_sym
    unless @components.has_key? component_id
      puts
      puts "not found: #{component_id.inspect}"
      puts "found: #{@components.keys.inspect}"
      puts
    end
    @components[ component_id ]
  end

  def export_to_client
    hash = {}
    @components.each do |component_id,component|
      hash[component_id.to_s] = component.export_to_client
    end
    hash
  end

  def setup
    @components = {}
    db.components.each do |component_id, component_spec|
      component_id = component_id.to_sym
      if component_spec['obsolete']
        component = ObsoleteComponent.new( @opt, component_id, component_spec )
      else
        component = Component.new( @opt, component_id, component_spec )
      end
      @components[component_id] = component
    end
  end
  
end; end

