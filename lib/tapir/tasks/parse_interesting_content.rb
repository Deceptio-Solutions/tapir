def name
  "parse_interesting_content"
end

def pretty_name
  "Parse For Interesting Content"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task parses the incoming entity's content for interesting content and create findings."
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

    # Scan for interesting content
    list = @entity.content.scan(/upload/im)
    list.each do |item|
      create_entity(Entities::Finding, {:name => "Content - File Upload String - #{@entity.name}",
        :content => @entity.content})
    end

    # Scan for interesting content
    list = @entity.content.scan(/administrator/im)
    list.each do |item|
      create_entity(Entities::Finding, {:name => "Content - Administrator String - #{@entity.name}",
        :content => @entity.content})
    end

    # Scan for interesting content
    list = @entity.content.scan(/password/im)
    list.each do |item|
      create_entity(Entities::Finding, {:name => "Content - Password String - #{@entity.name}",
        :content => @entity.content})
    end

    # Scan for interesting content
    list = @entity.content.scan(/<form/im)
    list.each do |item|
      create_entity(Entities::Finding, {:name => "Content - Form String - #{@entity.name}",
        :content => @entity.content})
    end

  end

end

def cleanup
  super
end
