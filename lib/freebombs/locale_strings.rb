
# Copyright 2011 Juha-Jarmo Heinonen <o@sorsacode.com>

module FreeBOMBS
  module LocaleMethods
    def str
      @opt[:strings]
    end
    def conf
      @opt[:config]
    end
    def md( md_src )
      return md_src unless $md_to_html
      BlueCloth.new( md_src ).to_html
    end
  end
  class LocaleStrings
    def method_missing( str_name )
      @data[str_name.to_s]
    end
    def initialize( data )
      @data = data
    end
  end
  class Price
    include LocaleMethods
    def to_euro
      @price
    end
    alias to_eur to_euro
    def to_usd
      @price * usd_rate
    end
    def price
      return to_eur if conf.currency == 'EUR'
      return to_usd if conf.currency == 'USD'
    end
    def initialize( price, currency='USD' )
      if currency == 'EUR'
        @price = price
      elsif currency == 'USD'
        @price = from_usd( price )
      end
    end
  private
    def usd_rate; 1.464; end
    def from_usd( price )
      price / usd_rate
    end
  end
end

