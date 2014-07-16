def name
  "robots_txt"
end

def pretty_name
  "Robots.txt search"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task grabs the robots.txt and adds a record with the contents"
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::Host, 
    Entities::DnsRecord, 
    Entities::WebApplication]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)

  if @entity.kind_of? Entities::Host
    url = "http://#{@entity.name}/robots.txt"
  elsif @entity.kind_of? Entities::DnsRecord
    url = "http://#{@entity.name}/robots.txt"
  else 
    # Web application's name is already a URI
    url = "#{@entity.name}/robots.txt"
  end
  
  begin
    @task_logger.log "Connecting to #{url} for #{@entity}" 

    # Prevent encoding errors
    contents = open("#{url}").read.force_encoding('UTF-8')

    # TODO - parse & use the lines as seed paths
    create_entity Entities::Finding, { :name => "Robots.txt - #{url}", :content => "#{url}" , :details => contents }

  rescue OpenURI::HTTPError => e
    @task_logger.error "Unable to connect: #{e}"
  rescue Net::HTTPBadResponse => e
    @task_logger.error "Unable to connect: #{e}"
  rescue OpenSSL::SSL::SSLError => e
    @task_logger.error "Unable to connect: #{e}"
  rescue EOFError => e
    @task_logger.error "Unable to connect: #{e}"
  rescue SocketError => e
    @task_logger.error "Unable to connect: #{e}"
  rescue RuntimeError => e
    @task_logger.error "Unable to connect: #{e}"
  rescue SystemCallError => e
    @task_logger.error "Unable to connect: #{e}"
  rescue ArgumentError => e
    @task_logger.error "Argument Error #{e}"
  rescue Encoding::InvalidByteSequenceError => e
    @task_logger.error "Encoding error: #{e}"
  rescue Encoding::UndefinedConversionError => e
    @task_logger.error "Encoding error: #{e}"
  end
end

## Default method, subclasses must override this
def run
  super
end

def cleanup
  super
end
