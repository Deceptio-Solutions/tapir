# Returns the name of this task.
def name
  "google_search"
end

def pretty_name
  "Google Search"
end

def authors
  ['jcran']
end

# Returns a string which describes this task.
def description
  "This task hits the Google API and finds related content. Discovered domains are created."
end

# Returns an array of valid types for this task
def allowed_types
  [ Entities::SearchString, 
    Entities::Organization, 
    Entities::DnsRecord, 
    Entities::Host,
    Entities::EmailAddress,
    Entities::Person, 
    Entities::Username, 
    Entities::Account]
end

def setup(entity, options={})
  super(entity, options)
  self
end

# Default method, subclasses must override this
def run
  super

  # Attach to the google service & search
  results = Client::Google::SearchService.new.search(@entity.name)

  results.each do |result|
    # Create a domain
    create_entity Entities::DnsRecord, :name => result[:visible_url]

    # Create the top-level domain
    create_entity Entities::DnsRecord, :name => result[:visible_url].split(".").last(2).join(".")

    #Handle Twitter search results
    if result[:title_no_formatting] =~ /on Twitter/
      account_name = result[:title_no_formatting].scan(/\(.*\)/).first[1..-2]
      create_entity(Entities::TwitterAccount, { :name => account_name,
      :uri => "http://www.twitter.com/#{account_name}" })
    
    # Handle Facebook search results
    elsif result[:unescaped_url] =~ /https:\/\/www.facebook.com/
      account_name = result[:unescaped_url].scan(/[^\/]+$/).first
      create_entity(Entities::FacebookAccount, { :name => account_name, 
        :uri => "http://www.facebook.com/#{account_name}" })
    
    # Handle LinkedIn search results
    elsif result[:unescaped_url] =~ /http:\/\/www.linkedin.com\/in/
      account_name = result[:unescaped_url].scan(/[^\/]+$/).first
      create_entity(Entities::LinkedinAccount, { :name => account_name,
      :uri => "http//www.linkedin.com/in/#{account_name}" })
    # Otherwise, just create a generic search result
    else
      create_entity(Entities::WebPage, {
        :name => result[:title_no_formatting],
        :uri => result[:unescaped_url],
        :content => result[:content]
      })
    end
  end

end

def cleanup
  super
end
