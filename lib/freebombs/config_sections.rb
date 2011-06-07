
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class ConfigSections
  def setup( section_order, sections )
    @section_order = []
    @sections_by_id = {}
    section_order.each do |section_id|
      section_spec = sections[section_id]
      section_id = section_id.to_sym
      @section_order.push( section_id )
      @sections_by_id[ section_id ] = ConfigSection.new( @opt, section_id, section_spec )
    end
  end
  def initialize( opt, section_order, sections )
    @opt = opt
    setup( section_order, sections )
  end
  def export
    arr = []
    @section_order.each do |section_id|
      arr.push @sections_by_id[ section_id ].export
    end
    arr
  end
end; end

