def name
  "built_with"
end

def pretty_name
  "Built With"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task determines platform and technologies of the target"
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::WebApplication]
end

def setup(entity, options={})
  super(entity, options)
  
  url = "#{@entity.name}"

  @task_logger.log "Connecting to #{url} for #{@entity}" 

  begin

    status = Timeout.timeout(30) do
      # Prevent encoding errors
      contents = open("#{url}", :allow_redirections => :safe).read #.force_encoding('UTF-8')

      contents.encode!('UTF-8', 'UTF-8', :invalid => :replace)

      target_strings = [

        ### Marketing / Tracking
        {:regex => /urchin.js/, :finding => "Google Analytics"},
        {:regex => /optimizely/, :finding => "Optimizely"},
        {:regex => /trackalyze/, :finding => "Trackalyze"},
        {:regex => /doubleclick.net|googleadservices/, :finding => "Google Ads"},
        {:regex => /munchkin.js/, :finding => "Marketo"},
        {:regex => /Olark live chat software/, :finding => "Olark"},

        ### External accounts
        {:regex => /http:\/\/www.twitter.com\/.*?/, :finding => "Twitter Account"},
        {:regex => /http:\/\/www.facebook.com\/.*?/, :finding => "Facebook Account"},

        ### Technologies
        #{:regex => /javascript/, :finding => "Javascript"},
        {:regex => /jquery.js/, :finding => "JQuery"},
        {:regex => /bootstrap.css/, :finding => "Twitter Bootstrap"},

        ### Platform
        {:regex => /[W|w]ordpress/, :finding => "Wordpress"},
        {:regex => /[D|d]rupal/, :finding => "Drupal"},

        ### Provider
        {:regex => /Content Delivery Network via Amazon Web Services/, :finding => "Amazon Cloudfront"},

        ### Wordpress Plugins
        { :regex => /wp-content\/plugins\/.*?\//, :finding => "Wordpress Plugin"},
        { :regex => /xmlrpc.php/, :finding => "Wordpress API"},
        #{:regex => /Yoast WordPress SEO plugin/, :finding => "Yoast Wordress SEO Plugin"},
        #{:regex => /PowerPressPlayer/, :finding => "Powerpress Wordpress Plugin"},
      ]

      target_strings.each do |target|
        matches = contents.scan(target[:regex]) #.map{Regexp.last_match}
        matches.each do |match|
          create_entity(Entities::Finding,
            { :name => "#{@entity.name} - #{target[:finding]}",
              :content => "Found #{match} on #{@entity.name}",
              :details => contents 
            })
        end if matches
      end
    end

  rescue Timeout::Error => e
    @task_logger.error "Timeout!"
  rescue OpenSSL::SSL::SSLError => e
    @task_logger.error "Unable to connect: #{e}"
  rescue OpenURI::HTTPError => e
    @task_logger.error "Unable to connect: #{e}"
  rescue Net::HTTPBadResponse => e
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
