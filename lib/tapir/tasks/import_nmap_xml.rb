def name
  "import_nmap_xml"
end

def pretty_name
  "Import Nmap XML"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This is a task to import nmap xml."
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::ParsableFile,
    Entities::ParsableText ]
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

  if @entity.kind_of? Entities::ParsableText
    text = @entity.text
  else #ParsableFile
    text = open(@entity.uri).read
  end
  
  # Create our parser
  hosts = []
  parser = Nmap::Parser.parsestring(text)

  # Create entitys for each discovered service
  parser.hosts("up") do |host|

    @task_logger.log "Handling nmap data for #{host.addr}"

    # Handle the case of a netblock or domain - where we will need to create host entity(s)
    if @entity.kind_of? Entities::NetBlock or @entity.kind_of? Entities::DnsRecord
      @host_entity = create_entity(Entities::Host, {:name => host.addr })
      @host_entity.dns_records << @entity if @entity.kind_of? Entities::DnsRecord

      #@host_entity.domains << @entity
    else
      @host_entity = @entity # We already have a host
    end

    [:tcp, :udp].each do |proto_type|
      host.getports(proto_type, "open") do |port|
      @task_logger.log "Creating Service: #{port}"
      
      entity = create_entity(Entities::NetSvc, {
        :name => "#{host.addr}:#{port.num}/#{port.proto}",
        :host_id => @host_entity.id,
        :port_num => port.num,
        :proto => port.proto,
        :fingerprint => "#{port.service.name} #{port.service.product} #{port.service.version}"})
      end

      # Go ahead and create webapps if this is a known webapp port 
      if entity.proto == "tcp" && [80,443,8080,8081,8443].include?(entity.port_num)
         # determine if this is an SSL application
        ssl = true if [443,8443].include? @entity.port_num
        
        # construct uri
        protocol = ssl ? "https://" : "http://"
        uri = "#{protocol}#{@entity.host.name}:#{@entity.port_num}"

        create_entity(Entities::WebApplication, {
          :name => uri,
          :host => entity.host,
          :netsvc => entity
        })
      end

    end

  end
  
end

def cleanup
  super
end
