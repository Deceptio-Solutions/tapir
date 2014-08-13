def name
  "masscan_top"
end

def pretty_name
  "Mass Scan Top Ports"
end

## Returns a string which describes what this task does
def description
  "This task runs a masscan scan for the top ports on the target range."
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
 
  ports = [ "U:162","U:49152","U:514","U:4500","25","U:1900","U:520",
            "U:500","22","U:139","21","443","U:53","23",
            "U:67","U:135","U:445","U:1434","U:123","U:137",
            "U:161","U:631","80","U:111","3389","U:4500"]
 
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

      # Create entity for each discovered host + service
      @host_entity = create_entity(Entities::Host, {:name => host })
      create_entity(Entities::NetSvc, {
        :name => "#{host}:#{port}/tcp",
        :host_id => @host_entity.id,
        :port_num => port,
        :proto => "tcp",
        :fingerprint => "masscanned"})
    end
  end
end

def cleanup
  super
  File.delete(@range_path)
  File.delete(@output_path)
end
