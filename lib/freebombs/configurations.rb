
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class Configurations

  include Logger

  include CommonMethods
  def opt_key; :configurations; end

  include LocaleMethods

  attr_reader :title, :description, :sections, :components

  def setup
    data = db.configurations
    @title = md( data['title'] )
    @description = md( data['description'] )
    @components = ComponentList.new( @opt, data['components'] )
    @sections = ConfigSections.new( @opt, data['section_order'], data['sections'] )
  end

  def components; @components; end

  def sections; @sections; end

  def export
    suppliers = @opt[:suppliers].supplier_ids
    { :suppliers => suppliers,
      :supplier => suppliers.first,
      :components => @components.export,
      :sections => @sections.export,
      :currency => @opt[:conf].currency.to_sym
    }
  end

end; end

