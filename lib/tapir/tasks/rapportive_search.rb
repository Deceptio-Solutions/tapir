def name
  "rapportive_search"
end

def pretty_name
  "Search the Rapportive database"
end

def authors
  ['jcran']
end

def description
  "Uses the Rapportive API to search for information"
end

def allowed_types
  [ Entities::EmailAddress ]
end

def setup(entity, options={})
  super(entity, options)
  @rapportive_client = Client::Rapportive::ApiClient.new
end

def run
  super
  response = @rapportive_client.search @entity.name
  @task_logger.log "Full log #{response.to_s}" 

  if response['contact']['memberships']
    response['contact']['memberships'].each do |m|
      create_entity(Entities::TwitterAccount, :name => m['username'],
        :uri => "http://www.twitter.com/#{m['username']}" ) if m['display_name'] == "Twitter"
      create_entity(Entities::FacebookAccount, :name => m['username'],
        :uri => "http://www.facebook.com/#{m['username']}") if m['display_name'] == "Facebook"
      create_entity(Entities::LinkedinAccount, :name => m['username'],
        :uri => "http://www.linkedin.com/in/#{m['username']}") if m['display_name'] == "LinkedIn"
      
      # These entity types don't exist yet - what else can rapportive provide?
      #create_entity(Entities::FlickrAccount, :name => m['username']) if m['display_name'] == "Flickr"
      #create_entity(Entities::GoogleAccount, :name => m['profile_id']) if m['display_name'] == "Google"
      #create_entity(Entities::GravatarAccount, :name => m['username']) if m['display_name'] == "Gravatar"
      #create_entity(Entities::VimeoAccount, :name => m['username']) if m['display_name'] == "Vimeo"
    end
  end

  if response['contact']['images']
    response['contact']['images'].each do |i|
      create_entity(Entities::RemoteImage,{:name => i['url']})
    end
  end

end

def cleanup
  super
end
