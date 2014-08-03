def name
  "dns_forward_lookup"
end

def pretty_name
  "DNS Forward Lookup"
end

def authors
  ['Felipe Molina (@felmoltor)', 'jcran']
end

## Returns a string which describes what this task does
def description
  "Query for the ip address of the given DNS name"
end

## Returns an array of valid types for this task
def allowed_types
  [Entities::DnsRecord]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
end

def run
  super

    begin
      resolved_address = Resolv.new.getaddress(@entity.name)
      
      if resolved_address
        @task_logger.good "Creating host entity for #{resolved_address}"
        h = create_entity(Entities::Host, {:name => resolved_address})
        # Set the host for this dns record
        @entity.host = h
        h.dns_records << @entity
      else
        @task_logger.log "Unable to find address for #{@entity.name}"
      end

    rescue Exception => e
      @task_logger.error "Hit exception: #{e}"
    end

end

def cleanup
  super
end
