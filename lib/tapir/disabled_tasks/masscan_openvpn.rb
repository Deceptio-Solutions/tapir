def name
  "masscan_openvpn"
end

def pretty_name
  "Mass Scan OpenVPN"
end

## Returns a string which describes what this task does
def description
  "This task runs a masscan scan for openvpn servers."
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::NetBlock]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
end

## Default method, subclasses must override this
def run
  super
  
  # Grab options
  masscan_options = @options['masscan_options']
 
  ports = [ "U:1194"]
 
  ports.each do |port|
    # Write the range to a path
    @output_path = "#{Dir::tmpdir}/masscan_output_#{rand(100000000)}.temp"

    # shell out to binary and run the scan
    @task_logger.log "scanning #{@entity.range}" 
    @task_logger.log "masscan options: #{masscan_options}"
  
    masscan_string = "sudo masscan -p #{port} #{@entity.range} > #{@output_path}" 
    @task_logger.log "calling masscan: #{masscan_string}"
    safe_system(masscan_string)
    
    # Gather the output and parse
    @task_logger.log "Raw Result:\n #{File.open(@output_path).read}"
    @task_logger.log "Parsing #{@output_path}"

    f = File.open(@output_path).each_line do |host_string|
      host_string = host_string.delete("\n").strip unless host_string.nil?
      host = host_string.split(" ").last
      
      proto = "tcp"
      if port =~ /^U/
        port = port.split(":").last
        proto = "udp"
      end

      # Create entity for each discovered host + service
      host_entity = create_entity(Entities::Host, {:name => host })
      
      ## Create the DNS Name
      begin
        resolved_name = Resolv.new.getname(host).to_s
        if resolved_name
          @task_logger.good "Creating domain #{resolved_name}"
          # Create our new dns record entity with the resolved name
          domain_entity = create_entity(Entities::DnsRecord, {:name => resolved_name})
          host_entity.dns_records << domain_entity
        else
          @task_logger.log "Unable to find a name for #{@entity.name}"
        end
      rescue Exception => e
        @task_logger.error "Hit exception: #{e}"
      end

      create_entity(Entities::NetSvc, {
        :name => "#{host}:#{port}/tcp",
        :host_id => host_entity.id,
        :port_num => port,
        :proto => proto,
        :fingerprint => "masscanned"})
    end
  end
end

def cleanup
  super
  File.delete(@output_path)
end