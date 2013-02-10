def name
  "robots_txt"
end

def pretty_name
  "Robots.txt search"
end

## Returns a string which describes what this task does
def description
  "This task grabs the robots.txt and adds a record with the contents"
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [Tapir::Entities::WebApp]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)

  if @entity.kind_of? Tapir::Entities::Host
    url = "http://#{@entity.ip_address}/robots.txt"
  else
    url = "http://www.#{@entity.name}/robots.txt"
  end
  
  begin
    @task_logger.log "Connecting to #{url} for #{@entity}" 

    # Prevent encoding errors
    contents = open("#{url}").read.force_encoding('UTF-8')

    # TODO - parse & use the lines as seed paths
    
  rescue OpenURI::HTTPError => e
    @task_logger.log "Unable to connect: #{e}"
  rescue Net::HTTPBadResponse => e
    @task_logger.log "Unable to connect: #{e}"
  rescue EOFError => e
    @task_logger.log "Unable to connect: #{e}"
  rescue SocketError => e
    @task_logger.log "Unable to connect: #{e}"
  rescue RuntimeError => e
    @task_logger.log "Unable to connect: #{e}"
  rescue SystemCallError => e
    @task_logger.log "Unable to connect: #{e}"
  rescue ArgumentError => e
    @task_logger.log "Argument Error #{e}"
  rescue Encoding::InvalidByteSequenceError => e
    @task_logger.log "Encoding error: #{e}"
  rescue Encoding::UndefinedConversionError => e
    @task_logger.log "Encoding error: #{e}"
  end
end

## Default method, subclasses must override this
def run
  super
end

def cleanup
  super
end
