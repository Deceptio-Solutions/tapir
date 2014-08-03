def name
  "web_scan"
end

def pretty_name
  "Web Scan"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task runs a web scan and adds webpages with interesting contents"
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

  # Base checklist
  to_check = [
    { :path => "crossdomain.xml", :signature => "<?xml" },
    { :path => "elmah.axd", :signature => "Error Log for" },
    { :path => "phpinfo.php", :signature => "phpinfo()" },
    { :path => "robots.txt", :signature => "user-agent:" },
    { :path => "sitemap.xml", :signature => "<?xml" },
    { :path => "sitemap.xml.gz", :signature => "<?xml" },
  ]

  # Add in un-sig'd checks 
  unsig_checks = IO.readlines("#{Rails.root}/data/web.list")
  unsig_check_list = unsig_checks.map { |x| { :path => x.chomp, :signature => "" } } 
  to_check += unsig_check_list

  test_url = "#{@entity.name}/there-is-no-way-this-exists-#{rand(10000)}"
  missing_page_content = do_http_request(test_url)

  # Run through the checks
  to_check.each do |check|

    # Concat the uri to create the check
    url = "#{@entity.name}/#{check[:path]}"

    @task_logger.log "Connecting to #{url} for #{@entity}" 

    # Do the request
    content = do_http_request(url)

    # Check to make sure this is a legit page, and create an entity if so
    # TODO - improve the checking for wildcard page returns and 404-200's
    if content.include? check[:signature] and content != missing_page_content

      # TODO - parse & use the lines as seed paths
      create_entity Entities::WebPage, { :name => "#{url}", :uri => "#{url}", :content => "#{content}" }

    end

  end
end

def do_http_request(url)
  begin

    # Prevent encoding errors
    content = open("#{url}").read.force_encoding('UTF-8')

    # Lots and lots of things to go wrong... wah wah.
    rescue OpenURI::HTTPError => e
      @task_logger.error "HTTPError - Unable to connect to #{url}: #{e}"
    rescue Net::HTTPBadResponse => e
      @task_logger.error "HTTPBadResponse-  Unable to connect to #{url}: #{e}"
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
end

def cleanup
  super
end
