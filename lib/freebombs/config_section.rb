
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class ConfigSection
  include LocaleMethods
  def has_components?; ( not @components.empty? ); end
  def has_exclusions?; ( not @exclusions.empty? ); end
  def excludes?( section_id )
    return false unless has_exclusions?
    @excludes.include?( section_id )
  end
  attr_reader :checked, :presets
  def checked?; @checked; end
  def presets?; ( not @presets.empty? ); end
  def setup( data )
    @title = md( data['title'] )
    @description = md( data['description'] )
    @value = data['value']
    @min = data['min']
    @max = data['max']
    if data.has_key?( 'components' )
      @components = ComponentList.new( @opt, data['components'] )
    else
      @components = ComponentList.new( @opt, data['components'] )
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
    @presets = []
    if data.has_key? 'presets'
      data['presets'].each do |preset|
        @presets.push( {
          :title => md( preset['title'] ),
          :value => preset['value']
        } )
      end
    end
  end
  def initialize( opt, section_id, section_spec )
    @id = section_id
    @opt = opt
    setup( section_spec )
  end
  def export
    { :id => @id,
      :title => @title,
      :description => @description,
      :value => @value,
      :min => @min,
      :max => @max,
      :checked => checked?,
      :excludes => @excludes,
      :presets => @presets,
      :components => @components.export
    }
  end
end; end
