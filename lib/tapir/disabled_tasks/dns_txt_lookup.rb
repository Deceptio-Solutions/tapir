require 'dnsruby'

def name
  "dns_txt_lookup"
end

def pretty_name
  "DNS TXT Record lookup"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "Query for txt records at this domain"
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

  @task_logger.log "Running TXT lookup on #{@entity}"

  begin
    res = Dnsruby::Resolver.new(
      :recurse => true, 
      :query_timeout => 5)

    res_answer = res.query(@entity.name, Dnsruby::Types.TXT)

    # If we got a success to the query.
    if res_answer
      @task_logger.good "TXT lookup succeeded on #{@entity.name}:\n #{res_answer.answer}"
      @task_logger.good "Answer: #{res_answer}"


      # TODO - Parse for netbocks and hostnames

#     res_answer.downcase.split("ipv4").
#     create_entity NetBlock, :range
      
      # Create a finding for each 
      unless res_answer.answer.count == 0
        res_answer.answer.each do |answer|
          create_entity Entities::Finding, { :name => "TXT Record", :content => answer , :details => res_answer }
        end
      end
      
    end

  rescue Dnsruby::Refused
    @task_logger.log "Zone Transfer against #{@entity.name} refused."

  rescue Dnsruby::ResolvError
    @task_logger.log "Unable to resolve #{@entity.name}"

  rescue Dnsruby::ResolvTimeout
    @task_logger.log "Timed out while querying #{@entity.name}."

  rescue Exception => e
    @task_logger.log "Unknown exception: #{e}"

  end

end

def cleanup
  super
end
