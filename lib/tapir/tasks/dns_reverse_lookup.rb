def name
  "dns_reverse_lookup"
end

def pretty_name
  "DNS Reverse Lookup"
end

def description
  "Look up the name of the given ip address"
end

## Returns an array of valid types for this task
def allowed_types
  [Entities::Host]
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

    resolved_name = Resolv.new.getname(@entity.name).to_s

    if resolved_name
      @task_logger.log_good "Creating domain #{name}"
      
      # Create our new domain entity with the resolved name
      d = create_entity(Entities::Domain, {:name => resolved_name})

      # Add the domain for this host
      @entity.domains << d
    else
      @task_logger.log "Unable to find a name for #{@entity.name}"
    end

  rescue Exception => e
    @task_logger.log_error "Hit exception: #{e}"
  end


end

def cleanup
  super
end

