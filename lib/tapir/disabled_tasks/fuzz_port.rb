require 'socket'

def name
  "fuzz_port"
end

def pretty_name
  "Fuzz Port"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task connects to a service and sends lots of random data"
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

  # Check to make sure we have a sane target
  if @entity.proto.downcase == "tcp"
    if @entity.host
      s = TCPSocket.new @entity.host.name, @entity.port_num 
    else
      @task_logger.log "No associated host"
      return
    end
  else
    @task_logger.log "Unknown protocol"
    return
  end

  # Probe the port
  begin
    Timeout.timeout(120) do
      while true
        s.puts "#{(0...50).map{ ('a'..'z').to_a[rand(26)] }.join}\n"
      end
    end
  rescue Timeout::Error
    @task_logger.log "Timed out"
  rescue Errno::ECONNRESET
    @task_logger.log "Connection Reset"
  end
  
  # Cleanup
  s.close
end

def cleanup
  super
end
