
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS; class Suppliers
  class Supplier
    attr_reader :id, :title, :homepage
    def initialize( opt, id, spec )
      @suppliers = opt[:suppliers]
      @id = id
      @title = spec['title']
      @homepage = spec['homepage']
      @currency = spec['currency']
    end
  end
  def method_missing( name )
    @suppliers[name] if @suppliers.has_key? name
  end
  def db
    @opt[:db_handler]
  end
  def supplier?( supplier_id )
    ( @suppliers.has_key? supplier_id.to_sym )
  end
  def supplier( supplier_id )
    @suppliers[ supplier_id.to_sym ]
  end
  def supplier_ids
    @suppliers.keys.sort
  end
  def setup
    @suppliers = {}
    db.suppliers.each do |supplier_id, supplier_spec|
      @suppliers[supplier_id.to_sym] = Supplier.new( @opt, supplier_id, supplier_spec )
    end
  end
  def initialize( opt )
    opt[:suppliers] = self
    @opt = opt
    setup
  end
end; end

