def name
  "twitter_api_query"
end

def pretty_name
  "Query Twitter for a given account"
end

def authors
  ['jcran']
end

# Returns a string which describes what this task does
def description
  "This task grabs information from Twitter for a given acount."
end

# Returns an array of types that are allowed to call this task
def allowed_types
  [Entities::TwitterAccount]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
end

# Default method, subclasses must override this
def run
  super

  client = Client::Twitter::ApiClient.new

  @task_logger.log "Searching for #{@entity.name}"
  details = client.query(@entity.name)

  @task_logger.log "Got result: #{details.inspect.to_s.html_safe}"
  create_entity(Entities::DnsRecord, {:name => "#{details['url']}"})
end

def cleanup
  super
end
