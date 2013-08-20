def name
  "example"
end

def pretty_name
  "Example Task"
end

## Returns a string which describes what this task does
def description
  "This is an example Tapir task. It associates a random host with the calling entity."
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::Account,
    Entities::DnsRecord, 
    Entities::DocFile,
    Entities::EmailAddress,
    Entities::FacebookAccount,
    Entities::Finding,
    Entities::Host, 
    Entities::Image,
    Entities::KloutAccount,
    Entities::NetBlock,
    Entities::NetSvc,
    Entities::Organization,
    Entities::ParsableFile,
    Entities::ParsableText,
    Entities::PdfFile,
    Entities::Person,
    Entities::PhysicalLocation, 
    Entities::SearchResult,
    Entities::SearchString, 
    Entities::TwitterAccount,
    Entities::Username,
    Entities::WebApplication,
    Entities::WebForm,
    Entities::WebPage,
    Entities::XlsFile ]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 [{ :option_name   => "test", 
    :option_type   => "String",
    :option_value  => "test" }]
end

def setup(entity, options={})
  super(entity, options)
end

## Default method, subclasses must override this
def run
  super
  # create an ip
  ip_address = "#{rand(255)}.#{rand(255)}.#{rand(255)}.#{rand(255)}"
  x = create_entity Entities::Host, { :name => ip_address }
end

def cleanup
  super
end
