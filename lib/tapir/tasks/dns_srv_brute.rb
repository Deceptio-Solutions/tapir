require 'resolv'

def name
  "dns_srv_brute"
end

def pretty_name
  "DNS SRV Brute"
end

# Returns a string which describes what this task does
def description
  "Simple DNS Service Record Bruteforce"
end

# Returns an array of valid types for this task
def allowed_types
  [Tapir::Entities::Domain]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
  
    @resolver  = Dnsruby::DNS.new # uses system default
  
  self
end

# Default method, subclasses must override this
def run
  super
  
  if @options['srv_list']
    subdomain_list = @options['srv_list']
  else
    # Add a builtin domain list  
    srv_list = [
      '_gc._tcp', '_kerberos._tcp', '_kerberos._udp', '_ldap._tcp',
      '_test._tcp', '_sips._tcp', '_sip._udp', '_sip._tcp', '_aix._tcp',
      '_aix._tcp', '_finger._tcp', '_ftp._tcp', '_http._tcp', '_nntp._tcp',
      '_telnet._tcp', '_whois._tcp', '_h323cs._tcp', '_h323cs._udp',
      '_h323be._tcp', '_h323be._udp', '_h323ls._tcp',
      '_h323ls._udp', '_sipinternal._tcp', '_sipinternaltls._tcp',
      '_sip._tls', '_sipfederationtls._tcp', '_jabber._tcp',
      '_xmpp-server._tcp', '_xmpp-client._tcp', '_imap.tcp',
      '_certificates._tcp', '_crls._tcp', '_pgpkeys._tcp',
      '_pgprevokations._tcp', '_cmp._tcp', '_svcp._tcp', '_crl._tcp',
      '_ocsp._tcp', '_PKIXREP._tcp', '_smtp._tcp', '_hkp._tcp',
      '_hkps._tcp', '_jabber._udp','_xmpp-server._udp', '_xmpp-client._udp',
      '_jabber-client._tcp', '_jabber-client._udp','_kerberos.tcp.dc._msdcs',
      '_ldap._tcp.ForestDNSZones', '_ldap._tcp.dc._msdcs', '_ldap._tcp.pdc._msdcs',
      '_ldap._tcp.gc._msdcs','_kerberos._tcp.dc._msdcs','_kpasswd._tcp','_kpasswd._udp'
    ]
  end

  @task_logger.log_good "Using srv list: #{srv_list}"

  srv_list.each do |srv|
    begin

      # Calculate the domain name
      domain = "#{srv}.#{@entity.name}"

      # Try to resolve
      @resolver.getresources(domain, "SRV").collect do |rec|

        # split up the record
        resolved_address = rec.target
        port = rec.port
        weight = rec.weight
        priority = rec.priority

        @task_logger.log_good "Resolved Address #{resolved_address} for #{domain}" if resolved_address

        # If we resolved, create the right entities
        if resolved_address
          @task_logger.log_good "Creating domain and host entities..."

          # Create a domain. pass down the organization if we have it.
          d = create_entity(Tapir::Entities::Domain, {:name => domain, :organization => @entity.organization })

          # Create a host to store the ip address
          h = create_entity(Tapir::Entities::Host, {:name => resolved_address})
          
          # Create a service, and also associate that with our host.
          create_entity(Tapir::Entities::NetSvc, {:proto => "tcp", :port_num => port, :host => h})

        end

      end
    rescue Exception => e
      @task_logger.log_error "Hit exception: #{e}"
    end


  end
end
