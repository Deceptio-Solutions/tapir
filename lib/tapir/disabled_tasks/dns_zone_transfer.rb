require 'dnsruby'

def name
  "dns_zone_transfer"
end

def pretty_name
  "DNS Zone Transfer"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "DNS Zone Tranfer"
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
    # Get the authoritative nameservers & query each of them
    answer = Whois::Client.new.lookup(@entity.name)
    resolved_list = nil
  rescue Exception => e
    @task_logger.log "Unable to query whois: #{e}"
  end  
  
  if answer 
    if answer.nameservers
      # For each authoritive nameserver
      answer.nameservers.each do |nameserver|
        begin
          @task_logger.log "Attempting Zone Transfer on #{@entity} against nameserver #{nameserver}"

          res = Dnsruby::Resolver.new(
            :nameserver => nameserver.to_s, 
            :recurse => true, 
            :use_tcp => true, 
            :query_timeout => 5)

          axfr_answer = res.query(@entity.name, Dnsruby::Types.AXFR)

          # If we got a success to the AXFR query.
          if axfr_answer

            # Do the actual zone transfer
            zt = Dnsruby::ZoneTransfer.new
            zt.transfer_type = Dnsruby::Types.AXFR
            zt.server = nameserver
            zone = zt.transfer(@entity.name)

            create_entity Entities::Finding, { :name => "Zone Transfer", :content => "#{nameserver} -> #{@entity.name}", :details => zone }

            # Create host records for each item in the zone
            zone.each do |z|
              if z.type == "A"
                h = create_entity Entities::Host, { :name => z.address.to_s }
                d = create_entity Entities::DnsRecord, { :name => z.name.to_s }
              elsif z.type == "CNAME"
                # TODO - recursively lookup cname host
                @task_logger.log "TODO - handle a CNAME record"
              elsif z.type == "MX"
                # TODO - recursively lookup cname host
                @task_logger.log "TODO - handle a MX record"
              elsif z.type == "NS"
                # TODO - recursively lookup cname host
                @task_logger.log "TODO - handle a NS record"
              end
            end

            # Record keeping
            @task_logger.good "Zone Tranfer Succeeded on #{@entity.name}"
            #@task_run.save_raw_result zone.to_s

          end

        rescue Dnsruby::Refused
          @task_logger.log "Zone Transfer against #{@entity.name} refused."

        rescue Dnsruby::ResolvError
          @task_logger.log "Unable to resolve #{@entity.name} while querying #{nameserver}."

        rescue Dnsruby::ResolvTimeout
          @task_logger.log "Timed out while querying #{nameserver} for #{@entity.name}."

        rescue Exception => e
          @task_logger.log "Unknown exception: #{e}"

        end
      end
    end
  else
    @task_logger.log "Domain WHOIS failed, we don't know what nameserver to query."
  end
end

def cleanup
  super
end
