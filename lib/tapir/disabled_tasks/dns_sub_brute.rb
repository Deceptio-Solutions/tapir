require 'resolv'

def name
  "dns_sub_brute"
end

def pretty_name
  "DNS Subdomain Brute"
end

def authors
  ['jcran']
end

# Returns a string which describes what this task does
def description
  "Simple DNS Subdomain Bruteforce"
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
  puts "CALLING SUPER!"
  super(entity, options)
  self
end

## Default method, subclasses must override this
  def run
    super

    # :subdomain_list => list of subdomains to brute
    # :mashed_domains => try domain names w/o a dot, see if anyone's hijacked a common "subdomain"

    if @options[:subdomain_list]
      subdomain_list = @options['subdomain_list']
    else
      # use the deepmagic list
      subdomain_list = IO.readlines("#{Rails.root}/data/dns_sub.list")
      # Add a builtin domain list  
      #subdomain_list = ["mx", "mx1", "mx2", "www", "ww2", "ns1", "ns2", "ns3", "test", "mail", "owa", "vpn", "admin",
      #  "gateway", "secure", "admin", "service", "tools", "doc", "docs", "network", "help", "en", "sharepoint", "portal",
      #  "public", "private", "pub", "zeus", "mickey", "time", "web", "it", "my", "photos", "safe", "download", "dl", 
      #  "search", "staging"]
    end

    @task_logger.good "Using subdomain list: #{subdomain_list}"

    result_list = []
    

    begin
      # Check for wildcard DNS, modify behavior appropriately. (Only create entities
      # when we know there's a new host associated)
      if Resolv.new.getaddress("noforkingway#{rand(100000)}.#{@entity.name}")
        wildcard_domain = true 
        @task_logger.error "WARNING! Wildcard domain detected, only saving validated domains/hosts."
      end
    rescue Resolv::ResolvError
      @task_logger.good "Looks like no wildcard dns. Moving on."
    end

    subdomain_list.each do |sub|
      sub = sub.chomp
      begin
        # Calculate the domain name
        if @options[:mashed_domains]
        
          # blatently stolen from HDM's webinar on password stealing, try without a dot to see
          # if this domain has been hijacked by someone - great for finding phishing attempts
          domain = "#{sub}#{@entity.name}"
        else  
          domain = "#{sub}.#{@entity.name}"
        end

        # Try to resolve
        resolved_address = Resolv.new.getaddress(domain)
        @task_logger.good "Resolved Address #{resolved_address} for #{domain}" if resolved_address
        
        # If we resolved, create the right entitys
        if resolved_address
          unless wildcard_domain
            @task_logger.good "Creating domain and host entities..."
            # create new host and domain entitys
            d = create_entity(Entities::DnsRecord, {:name => domain })
            h = create_entity(Entities::Host, {:name => resolved_address})
          else
            # Check to make sure we don't already have this host, if we don't 
            # we probably want to save the domain as a new entity (and the host)
            if Entities::Host.where(:name => resolved_address).count == 0
              d = create_entity(Entities::DnsRecord, {:name => domain })
              h = create_entity(Entities::Host, {:name => resolved_address})
            end
          end
        end
      rescue Exception => e
        @task_logger.error "Hit exception: #{e}"
      end
    end
  end
