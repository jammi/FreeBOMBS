
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
      html = BlueCloth.new( md_src ).to_html
      if html.start_with?('<p>') and html.end_with?('</p>') and html.rindex('<p>') == 0
        html = html[3..-5]
      end
      html
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
    def to_eur
      @price
    end
    alias to_euro to_eur
    def to_usd
      @price * usd_rate
    end
    def to_currency( currency=conf.currency )
      return to_eur if currency == :EUR
      return to_usd if currency == :USD
    end
    def initialize( price, currency=:USD )
      if currency == :EUR
        @price = price
      elsif currency == :USD
        @price = from_usd( price )
      else
        throw "Invalid currency: #{currency.inspect}"
      end
    end
  private
    def usd_rate; 1.464; end
    def from_usd( price )
      price / usd_rate
    end
  end
end

