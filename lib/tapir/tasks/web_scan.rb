require 'open_uri_redirections'

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
end

## Default method, subclasses must override this
def run
  super

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
  missing_page_content = open_uri_and_return_content(test_url)

  # Run through the checks
  to_check.each do |check|

    # Concat the uri to create the check
    url = "#{@entity.name}/#{check[:path]}"

    @task_logger.log "Connecting to #{url} for #{@entity}" 

    # Do the request
    content = open_uri_and_return_content(url)

    # Check to make sure this is a legit page, and create an entity if so
    # 
    # Note that the signature is blank for unsig_checks
    #
    # TODO - improve the checking for wildcard page returns and 404-200's
    if content.include? check[:signature] and content != missing_page_content

      # create an entity if we match
      create_entity Entities::WebPage, { :name => "#{url}", :uri => "#{url}", :content => "#{content}" }

    end

  end
end

def cleanup
  super
end
