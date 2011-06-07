
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class ConfigSection
  include LocaleMethods
  def has_components?; ( not @components.nil? ); end
  def has_exclusions?; ( not @exclusions.empty? ); end
  def excludes?( section_id )
    return false unless has_exclusions?
    @excludes.include?( section_id )
  end
  def checked?; @checked; end
  attr_reader :checked
  def presets?; ( not @presets.nil? ); end
  attr_reader :presets
  def setup( data )
    @title = md( data['title'] )
    @description = md( data['description'] )
    @value = data['value']
    @min = data['min']
    @max = data['max']
    if data.has_key?( 'components' )
      @components = ComponentList.new( @opt, data['components'] )
    else
      @components = nil
    end
    @excludes = []
    if data.has_key? 'excludes'
      excludes = data['excludes']
      excludes = [ excludes ] unless excludes.class == Array
      excludes.each { |section_id| @excludes.push section_id.to_sym }
    end
    if data.has_key? 'checked'
      @checked = data['checked']
    else
      @checked = false
    end
    if data.has_key? 'presets'
      @presets = []
      data['presets'].each do |preset|
        @presets.push( {
          :title => md( preset['title'] ),
          :value => preset['value']
        } )
      end
    else
      @presets = nil
    end
  end
  def initialize( opt, section_id, section_spec )
    @id = section_id
    @opt = opt
    setup( section_spec )
  end
end; end
