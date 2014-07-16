def name
  "shodan_search"
end

def pretty_name
  "Search the SHODAN database"
end

def authors
  ['jcran']
end

def description
  "Uses the SHODAN API to search for information"
end

def allowed_types
  [ Entities::SearchString ]
end

def setup(entity, options={})
  super(entity, options)
  @client = Client::Shodan::ApiClient.new
end

def run
  super

  if @entity.class == Entities::SearchString
    response = @client.search(@entity.name)
  else 
    raise "Unknown Entity Type"
  end 

  # check to make sure we got a response. 
  unless response
    @task_logger.error "Got no response from SHODAN. Are you sure you've configured the key?"
    return 
  end

  if response['matches']
    response['matches'].each do |response|
      @task_logger.log "* SHODAN Record *"       

      #updated_at = DateTime.new(response['updated'])
      updated_at = DateTime.now 

      # Create a host record
      @task_logger.log "IP: #{response['ip']}"
      host = create_entity(Entities::Host,{
        :name => "#{response['ip']}",
        :age => updated_at
      }) if response['ip']

      # Create a dns record for all hostnames
      response["hostnames"].each do |h| 
        @task_logger.log "Hostname: #{h}" 
        d = create_entity(Entities::DnsRecord,{
          :name => "#{h}", 
          :age => updated_at
        })
        d.host = host
        d.save
      end

      # Create a netsvc
      @task_logger.log "Port: #{response['port']}"
      port = create_entity(Entities::NetSvc,{
        :name => "#{host.name}:#{response['port']}/tcp",
        :proto => "tcp",
        :port_num => response['port'],
        :fingerprint => response['data'],
        :age => updated_at
      }) if response['port']
      port.host = host
      port.save

      # Create an organization
      @task_logger.log "Org: #{response['org']}"
      org = create_entity(Entities::Organization,{
        :name => "#{response['org']}",
        :age => updated_at
      }) if response['org']

      # Create a PhysicalLocation
      @task_logger.log "Location: #{response['postal_code']}"
      location = create_entity(Entities::PhysicalLocation,{
        :name => "#{response['latitude']} / #{response['longitude']}",
        :zip => "#{response['postal_code']}",
        :state => "#{response['region_name']}",
        :country => "#{response['country_name']}",
        :latitude => "#{response['latitude']}",
        :longitude => "#{response['longitude']}",
        :age => updated_at
      }) if response['country_name']


      #@task_logger.log "Port: #{response['port']}"
      #@task_logger.log "Port Data: #{response['data']}"
      #@task_logger.log "Country: #{response['country_name']}"
      #@task_logger.log "Country Code: #{response['country_code']}"
      #@task_logger.log "Region Name: #{response['region_name']}"
      #@task_logger.log "Area Code: #{response['area_code']}"
      #@task_logger.log "DMA Code: #{response['dma_code']}"
      #@task_logger.log "Postal Code: #{response['postal_code']}"
      #@task_logger.log "Org: #{response['org']}"
      @task_logger.log "Response: #{response.inspect}"
      #@task_logger.log " "       
    end  
  end

end

def cleanup
  super
end
