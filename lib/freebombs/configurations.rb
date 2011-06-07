
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class Configurations

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

end; end

