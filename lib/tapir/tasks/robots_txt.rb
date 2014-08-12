require 'open_uri_redirections'

def name
  "robots_txt"
end

def pretty_name
  "Find and parse robots.txt"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task grabs the robots.txt and adds each line as a web page"
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::WebApplication ]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
end

def do_http_request(url)
  begin

    # Prevent encoding errors
    content = open("#{url}", :allow_redirections => :safe).read.force_encoding('UTF-8')

    # Lots and lots of things to go wrong... wah wah.
    rescue OpenURI::HTTPError => e
      @task_logger.error "HTTPError - Unable to connect to #{url}: #{e}"
    rescue Net::HTTPBadResponse => e
      @task_logger.error "HTTPBadResponse - Unable to connect to #{url}: #{e}"
    rescue OpenSSL::SSL::SSLError => e
      @task_logger.error "SSLError - Unable to connect to #{url}: #{e}"
    rescue EOFError => e
      @task_logger.error "EOFError - Unable to connect to #{url}: #{e}"
    rescue SocketError => e
      @task_logger.error "SocketError - Unable to connect to #{url}: #{e}"
    rescue RuntimeError => e
      @task_logger.error "RuntimeError - Unable to connect to #{url}: #{e}"
    rescue SystemCallError => e
      @task_logger.error "SystemCallError - Unable to connect to #{url}: #{e}"
    rescue ArgumentError => e
      @task_logger.error "Argument Error - #{e}"
    rescue URI::InvalidURIError => e
      @task_logger.error "InvalidURIError - #{url} #{e}"
    rescue Encoding::InvalidByteSequenceError => e
      @task_logger.error "InvalidByteSequenceError - #{e}"
    rescue Encoding::UndefinedConversionError => e
      @task_logger.error "UndefinedConversionError - {e}"
    end

content || ""
end


## Default method, subclasses must override this
def run
  super

  checks = [{ :path => "robots.txt", :signature => "User-agent" }]

  checks.each do |check|
    # Concat the uri to create the check
    url = "#{@entity.name}/#{check[:path]}"

    @task_logger.log "Connecting to #{url} for #{@entity}" 

    # Grab a known-missing page so we can make sure it's not a 
    # 404 disguised as a 200
    test_url = "#{@entity.name}/there-is-no-way-this-exists-#{rand(10000)}"
    missing_page_content = do_http_request(test_url)

    # Do the request
    content = do_http_request(url)

    # Check to make sure this is a legit page, and create an entity if so
    # TODO - improve the checking for wildcard page returns and 404-200's
    if content.include? check[:signature] and content != missing_page_content

      # for each line of the file
      content.each_line do |line|
        
        # don't add comments
        next if line =~ /^#/
        next if line =~ /^User-agent/

        # This will work for the following types
        # Disallow: /path/
        # Sitemap: http://site.com/whatever.xml.gz
        if line =~ /Sitemap/
          path = line.split(" ").last.strip
          full_path = "#{path}"
        elsif line =~ /Disallow/
          path = line.split(" ").last.strip
          full_path = "#{@entity.name}#{path}"
        end

        # otherwise create a webpate 
        create_entity Entities::WebPage, { :name => full_path, :uri => full_path, :content => "#{content}" }
      end

    end

  end

end

def cleanup
  super
end
