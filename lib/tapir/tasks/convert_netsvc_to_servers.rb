def name
  "convert_netsvc_to_servers"
end

def pretty_name
  "Convert NetSvc to Servers"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "Convert all NetSvc to the appropriate Server types"
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [Entities::NetSvc]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
end

## Default method, subclasses must override this
def run
  super

# This method likely will not work anymore, as entities do not have hosts
# tied directly to them. Expect we'll have to go through the parents for a 
# Host type, and then depending on the port number, choose the appropriate
# type of server

return @task_logger.error "No associated host :(" unless @entity.host

server_types = [  
  {:port_num => 21,   :proto => "tcp", :entity_type => Entities::FtpServer, :entity_name => "#{@entity.host.name}" },
  {:port_num => 22,   :proto => "tcp", :entity_type => Entities::SshServer, :entity_name => "#{@entity.host.name}" },
  {:port_num => 23,   :proto => "tcp", :entity_type => Entities::TelnetServer, :entity_name => "#{@entity.host.name}" },
  {:port_num => 53,   :proto => "udp", :entity_type => Entities::DnsServer, :entity_name => "#{@entity.host.name}" }, 
  {:port_num => 80,   :proto => "tcp", :entity_type => Entities::WebApplication, :entity_name => "http://#{@entity.host.name}" },
  {:port_num => 443,  :proto => "tcp", :entity_type => Entities::WebApplication, :entity_name => "https://#{@entity.host.name}" },
  {:port_num => 8080, :proto => "tcp", :entity_type => Entities::WebApplication, :entity_name => "http://#{@entity.host.name}" },
  {:port_num => 8081, :proto => "tcp", :entity_type => Entities::WebApplication, :entity_name => "http://#{@entity.host.name}" },
  {:port_num => 8443, :proto => "tcp", :entity_type => Entities::WebApplication, :entity_name => "https://#{@entity.host.name}" }
]

# for each of the types we know about above
server_types.each do |s| 

  # check to see if this server type matches
  if @entity.port_num == s[:port_num] and @entity.proto == s[:proto]
    create_entity(s[:entity_type], { :name => s[:entity_name], :host => @entity.host} )
  end

end

=begin
  # determine if this is an SSL application
  ssl = true if [443,8443].include? @entity.port_num
  
  # construct uri
  protocol = ssl ? "https://" : "http://"
  uri = "#{protocol}#{@entity.host.name}:#{@entity.port_num}"

  # Create a web application entity based on the service
  create_entity(Entities::WebApplication, {
    :name => uri,
    :host => @entity.host,
    :netsvc => @entity
  })

  # Resolve DNS records for this netsvc
  begin
    resolved_name = Resolv.new.getname(@entity.host.name).to_s
    if resolved_name
      # Create our new dns record entity with the resolved name
      d = create_entity(Entities::DnsRecord, {:name => resolved_name})
      # Add the dns record for this host
      @entity.host.dns_records << d
    else
      @task_logger.log "Unable to find a name for #{@entity.name}"
    end
  rescue Exception => e
    @task_logger.error "Hit exception: #{e}"
  end

  # For each attached dns record, do the same
  @entity.host.dns_records.each do |d|
    uri = "#{protocol}#{d.name}:#{@entity.port_num}"
    create_entity(Entities::WebApplication, {
      :name => uri,
      :host => @entity.host,
      :netsvc => @entity
    })
  end
=end
end

def cleanup
  super
end
