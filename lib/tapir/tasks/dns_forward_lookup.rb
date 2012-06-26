def name
  "dns_forward_lookup"
end

## Returns a string which describes what this task does
def description
  "Forward DNS Lookup"
end

## Returns an array of valid types for this task
def allowed_types
  [Domain]
end

def setup(entity, options={})
  super(entity, options)
end

def run
  super

    begin
      resolved_address = Resolv.new.getaddress(@entity.name)
      
      if resolved_address
        @task_logger.log_good "Creating host entity for #{resolved_address}"
        h = create_entity(Host, {:ip_address => resolved_address})
        
        @entity.hosts << h
        h.domains << @entity
        
        # save the raw data
        #@task_run.save_raw_result resolved_address

      else
        @task_logger.log "Unable to find address for #{@entity.name}"
      end

    rescue Exception => e
      @task_logger.log_error "Hit exception: #{e}"
    end

end

def cleanup
  super
end
