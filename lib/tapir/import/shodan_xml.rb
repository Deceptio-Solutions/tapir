#
# <host city="Culver City" country="USA" hostnames="pwa206.wildgate.net" ip="66.52.2.206" port="23" updated="13.08.2010">
# <data>
#   Lantronix MSS1 Version STI3.5/5(981103)
#   Type HELP at the 'Local_2&gt; ' prompt for assistance.
#   Login password&gt; `
#  </data>
#</host>
#
#

#
# Sax parsing sucks. TODO - rewrite this with the Reader API
# http://stackoverflow.com/questions/9984621/sax-parsing-strange-element-with-nokogiri
#

module Import

class ShodanXml < Nokogiri::XML::SAX::Document

  attr_accessor :shodan_hosts
  def initialize(hosts)
    @hosts = hosts
  end

  def start_element(name, attrs = [])
    #@content = ""
    @attrs = attrs
    
    if name == "host"
      #
      # create a host entity & set the vars
      #
      current_host = ShodanHost.new
      @attrs.each do |attr|
        current_host.city = attr.last if attr.first == "city"
        current_host.country = attr.last if attr.first == "country"
        current_host.ip_address = attr.last if attr.first == "ip"
        current_host.hostnames = attr.last if attr.first == "hostnames"
        current_host.port = attr.last if attr.first == "port"
        current_host.updated = attr.last if attr.first == "city"
      end
      
      @hosts << current_host
    end
  
    #if name == "data"
    #  #
    #  # This always follows a host entity, so let's add the port & associate 
    #  #
    #  @hosts.last.services << ShodanService.new(@current_port, @content)
    #  @current_port=nil
    #end

  end

  #def characters(string)
  #  @content << string if @content
  #end
  
  #def cdata_block(string)
  #  characters(string)
  #end

  #def end_element(name)
    # Reset this so we don't grab content accidentally
    #@content = nil
  #end
  
end

class ShodanHost
    attr_accessor :city, :country, :hostname, :ip_address, :port, :updated
    def initialize(city=nil, country=nil, hostname=[], ip_address=nil, port=[], updated=nil)
      @city = city
      @country = country
      @hostname = hostname
      @ip_address = ip_address
      @port = port
      @updated = updated
    end
end

class ShodanService
  attr_accessor :num, :data
  def initialize(num=nil,data=nil)
    @num = num
    @data = data
  end
end

end