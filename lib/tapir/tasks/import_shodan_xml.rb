def name
  "import_shodan_xml"
end

def pretty_name
  "Import SHODAN XML"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This is a task to import SHODAN xml."
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
    text = open_uri_and_return_content(@entity.uri,@task_logger)
  end
  
  #@task_logger.log "Parsing #{text}"

  # Create our parser
  hosts = []
  shodan_xml = Import::ShodanXml.new(hosts)
  parser = Nokogiri::XML::SAX::Parser.new(shodan_xml)
  parser.parse(text)

  @task_logger.log "Parsing hosts: #{hosts}"
  
  hosts.each do |host|
    
    #
    # Create the entity for each host we know about
    #
    @task_logger.log "Creating #{host}"
    
    #d = create_entity(Entities::DnsRecord, { :name => host.hostnames }) if host.hostnames.kind_of? String
    h = create_entity(Entities::Host, {:name => host.ip_address })
    #p = create_entity(Entities::PhysicalLocation, {:city => host.city, :country => host.country})

    #host.services.each do |shodan_service|
    #  #
    #  # Create the service and associate it with our host above
    #  #
    #create_entity(Entities::NetSvc, {
    # :port_num => shodan_service.port,
    # :type => "tcp",
    # :fingerprint => shodan_service.data })
    #
    #end # End services processing

  end # End host processing
  
end

def cleanup
  super
end
