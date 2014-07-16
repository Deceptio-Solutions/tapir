def name
  "parse_entities"
end

def pretty_name
  "Parse Entities"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task parses the incoming entity's content for more entities."
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::WebPage ]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
  { :test =>
      { :type   => String,
        :value  => "test" }
  }
end

def setup(entity, options={})
  super(entity, options)
end

## Default method, subclasses must override this
def run
  super

  if @entity.content
    # Scan for email addresses
    addrs = @entity.content.scan(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,8}/)
    addrs.each do |addr|
      create_entity(Entities::EmailAddress, {:name => addr})
    end

    # Scan for dns records
    dns_records = @entity.content.scan(/^[A-Za-z0-9]+\.[A-Za-z0-9]+\.[a-zA-Z]{2,6}$/)
    dns_records.each do |dns_record|
      create_entity(Entities::DnsRecord, {:name => addr})
    end

    # Scan for links - This requires more work, we don't want relative links here.
    #
    #parsed_data = Nokogiri::HTML.parse @entity.content
    #anchor_tags = parsed_data.xpath("//a[@href]")
    #
    #anchor_tags.each do |link|
    #  create_entity(Entities::WebPage, {:name => link[:href]})
    #end

  end

end

def cleanup
  super
end
