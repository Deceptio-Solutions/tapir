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
    missing_page_content = open_uri_and_return_content(test_url)

    # Do the request
    content = open_uri_and_return_content(url)

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
