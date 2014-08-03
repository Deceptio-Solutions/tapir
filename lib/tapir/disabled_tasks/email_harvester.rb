# Returns the name of this task.
def name
  "email_harvester"
end

def pretty_name
  "Email Harvester"
end

def authors
  ['jcran']
end

# Returns a string which describes this task.
def description
  "This task scrapes email addresses via search engines."
end

# Returns an array of valid types for this task
def allowed_types
  [ Entities::DnsRecord ]
end

def setup(entity, options={})
  super(entity, options)
  self
end

# Default method, subclasses must override this
def run
  super

  # Bing
  @task_logger.log "Scraping Bing for email addresses"
  responses = Client::Bing::SearchScraper.new.search("#{@entity.name}+email")
  email_list = []
  responses.each do |r| 
    # Bing auto-bolds these
    r.gsub!("<strong>","") 
    r.gsub!("</strong>", "")
    r.scan(/[A-Z0-9]+@#{@entity.name}/i) do |email_address|
      create_entity Entities::EmailAddress, :name => email_address, :comment => "Scraped via Bing"
    end
  end

  # Google
  @task_logger.log "Scraping Google for email addresses"
  responses = Client::Google::SearchScraper.new.search("@#{@entity.name}+email")
  email_list = []
  responses.each do |r| 
    # Bing auto-bolds these
    r.gsub!("<b>","") 
    r.gsub!("</b>", "")
    r.scan(/[A-Z0-9]+@#{@entity.name}/i) do |email_address|
      create_entity Entities::EmailAddress, :name => email_address, :comment => "Scraped via google"
    end
  end

end

def cleanup
  super
end
