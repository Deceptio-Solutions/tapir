def name
  "rapleaf_search"
end

def pretty_name
  "Search the Rapleaf database"
end

def authors
  ['jcran']
end

def description
  "Uses the Rapleaf API to search for information"
end

def allowed_types
  [ Entities::EmailAddress ]
end

def setup(entity, options={})
  super(entity, options)
  @rapleaf_client = Client::Rapleaf::ApiClient.new
end

def run
  super
  response = @rapleaf_client.search @entity.name
  @task_logger.log "#{@entity.name} -> #{response}"
end

def cleanup
  super
end
