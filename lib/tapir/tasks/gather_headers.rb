def name
  "gather_headers"
end

def pretty_name
  "Check for security-related headers"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task checks for security headers on a web application"
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [Entities::WebApplication]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
end

def http_fetch(uri_str,limit = 10)
    # You should choose better exception.
    begin
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      
      Timeout.timeout(20) do

        url = URI.parse(uri_str)
        http = Net::HTTP.new(url.host, url.port)
        http.read_timeout = 1000
        http.use_ssl = (url.scheme == 'https')
        request = Net::HTTP::Get.new(uri_str)
        response = http.start {|http| http.request(request) }
        
        case response
          when Net::HTTPSuccess
            return response
          when Net::HTTPRedirection
            http_fetch(response['location'], limit - 1)
        end
      end
      
    rescue Timeout::Error
      @task_logger.log "Timed out"
    rescue Errno::ECONNREFUSED
      @task_logger.log "unable to connect"
    rescue OpenSSL::SSL::SSLError
      @task_logger.log "SSL connect error"
    rescue Timeout::Error => e
      @task_logger.log "Timeout! #{e}"
    rescue Net::HTTPBadResponse => e
      @task_logger.log "Unable to connect: #{e}"
    rescue EOFError => e
      @task_logger.log "Unable to connect: #{e}"
    rescue SocketError => e
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
    
  response
  end


## Default method, subclasses must override this
def run

  response = http_fetch(@entity.name)

  # Shortcut
  if response
    response.each_header do |name,value|
      create_entity(Entities::WebApplicationHeader, {
        :name => "#{name}: #{value}", 
        :content => "#{name}: #{value}" })
    end
  end

end

def cleanup
  super
end
