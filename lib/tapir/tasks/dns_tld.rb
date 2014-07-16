require 'resolv'

def name
  "dns_tld"
end

def pretty_name
  "DNS TLD"
end

def authors
  ['jcran']
end

# Returns a string which describes what this task does
def description
  "Add an entity for record's TLD"
end

# Returns an array of valid types for this task
def allowed_types
  [Entities::DnsRecord]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)  
  self
end

# Default method, subclasses must override this
def run
  super

  create_entity Entities::DnsRecord, :name => @entity.name.split('.').pop(2).join(".")

end
