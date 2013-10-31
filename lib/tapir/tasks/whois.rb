def name
  "whois"
end

def pretty_name
  "WHOIS Lookup"
end

## Returns a string which describes what this task does
def description
  "Perform a whois lookup for a given entity"
end

## Returns an array of valid types for this task
def allowed_types
  [ Entities::Host, 
    Entities::DnsRecord]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 [{:timeout => {:description => "Timeout for the query", :type => Integer }}]
end

def setup(entity, options={})
  super(entity, options)
end

def run
  super

  #
  # Set up & make the query
  #
  begin 
    whois = Whois::Client.new(:timeout => 20)
    answer = whois.lookup @entity.name 
  rescue Whois::Error => e
    @task_logger.log "Unable to query whois: #{e}"
  rescue Whois::ResponseIsThrottled => e
    @task_logger.log "Got a response throttled message: #{e}"
    sleep 10
    return run # retry
  rescue StandardError => e
    @task_logger.log "Unable to query whois: #{e}"
  rescue Exception => e
    @task_logger.log "UNKNOWN EXCEPTION! Unable to query whois: #{e}"
  end

  #
  # Check first to see if we got an answer back
  #
  if answer
    
    # Log the full text of the answer
    @task_logger.log "== Full Text: =="
    @task_logger.log answer.parts.first.body
    @task_logger.log "================"

    #
    # if it was a domain, we've got a whole lot of shit we can scoop
    #
    if @entity.kind_of? Entities::DnsRecord
      #
      # We're going to have nameservers either way?
      #
      if answer.nameservers
        answer.nameservers.each do |nameserver|
          #
          # If it's an ip address, let's create a host record
          #
          if nameserver.to_s =~ /\d\.\d\.\d\.\d/
            new_entity = create_entity Entities::Host , :name => nameserver.to_s
          else
            #
            # Otherwise it's another domain, and we can't do much but add it
            #
            new_entity = create_entity Entities::DnsRecord, :name => nameserver.to_s
          end
        end
      end

      #
      # Set the record properties
      #
      @entity.disclaimer = answer.disclaimer
      #@entity.domain = answer.domain
      #@entity.referral_whois = answer.referral_whois
      @entity.status = answer.status
      @entity.registered = answer.registered?
      @entity.available = answer.available?
      if answer.registrar
        @entity.registrar_name = answer.registrar.name
        @entity.registrar_org = answer.registrar.organization
        @entity.registrar_url = answer.registrar.url
      end
      @entity.record_created_on = answer.created_on
      @entity.record_updated_on = answer.updated_on
      @entity.record_expires_on = answer.expires_on
      
      @entity.full_text = answer.parts.first.body

      #
      # Create a user from the technical contact
      #
      begin
        if answer.technical_contact
          @task_logger.log "Creating user from technical contact"
          create_entity(Entities::Person, {:name => answer.technical_contact.name})
        end
      rescue Exception => e 
        @task_logger.log "Unable to grab technical contact" 
     end

      #
      # Create a user from the admin contact
      #
      begin
        if answer.admin_contact
          @task_logger.log "Creating user from admin contact"
          create_entity(Entities::Person, {:name => answer.admin_contact.name})
        end
      rescue Exception => e 
        @task_logger.log "Unable to grab admin contact" 
     end

      #
      # Create a user from the registrant contact
      #
      begin
        if answer.registrant_contact
          @task_logger.log "Creating user from registrant contact"
          create_entity(Entities::Person, {:name => answer.registrant_contact.name})
        end
      rescue Exception => e 
        @task_logger.log "Unable to grab registrant contact" 
     end

    @entity.save!

    #
    # Otherwise our entity must've been a host
    #
    else 
      #
      # Parse out the netrange - WARNING SUPERGHETTONESS ABOUND
      #

=begin
      <?xml version='1.0'?>
      <?xml-stylesheet type='text/xsl' href='http://whois.arin.net/xsl/website.xsl' ?>
      <net xmlns="http://www.arin.net/whoisrws/core/v1" xmlns:ns2="http://www.arin.net/whoisrws/rdns/v1" xmlns:ns3="http://www.arin.net/whoisrws/netref/v2" termsOfUse="https://www.arin.net/whois_tou.html">
        <registrationDate>2009-09-21T17:15:11-04:00</registrationDate>
        <ref>http://whois.arin.net/rest/net/NET-8-8-8-0-1</ref>
        <endAddress>8.8.8.255</endAddress>
        <handle>NET-8-8-8-0-1</handle>
        <name>LVLT-GOOGL-1-8-8-8</name>
        <netBlocks><netBlock>
        <cidrLength>24</cidrLength>
        <endAddress>8.8.8.255</endAddress>
        <description>Reassigned</description>
        <type>S</type>
        <startAddress>8.8.8.0</startAddress>
        </netBlock></netBlocks>
        <orgRef name="Google Incorporated" handle="GOOGL-1">http://whois.arin.net/rest/org/GOOGL-1</orgRef>
        <parentNetRef name="LVLT-ORG-8-8" handle="NET-8-0-0-0-1">http://whois.arin.net/rest/net/NET-8-0-0-0-1</parentNetRef>
        <startAddress>8.8.8.0</startAddress>
        <updateDate>2009-09-21T17:15:11-04:00</updateDate>
        <version>4</version>
      </net>  
=end
      doc = Nokogiri::XML(open ("http://whois.arin.net/rest/ip/#{@entity.name}"))
      org_ref = doc.xpath("//xmlns:orgRef").text
      parent_ref = doc.xpath("//xmlns:parentNetRef").text
      handle = doc.xpath("//xmlns:handle").text

      # For each netblock, create an entity
      doc.xpath("//xmlns:net/xmlns:netBlocks").children.each do |netblock|
        # Grab the relevant info
        
        cidr_length = ""
        start_address = ""
        end_address = ""
        block_type = ""
        description = ""

        netblock.children.each do |child|

          cidr_length = child.text if child.name == "cidrLength"
          start_address = child.text if child.name == "startAddress"
          end_address = child.text if child.name == "endAddress"
          block_type = child.text if child.name == "type"
          description = child.text if child.name == "description"

        end # End netblock children
          
        #
        # Create the netblock entity
        #
        entity = create_entity Entities::NetBlock, {
          :name => "#{start_address}/#{cidr_length}",
          :start_address => "#{start_address}",
          :end_address => "#{end_address}",
          :cidr => "#{cidr_length}",
          :description => "#{description}",
          :block_type => "#{block_type}",
          :handle => handle,
          :organization_reference => org_ref,
          :parent_reference => parent_ref
        }

      end # End Netblocks

    end # end Host Type

  else
    @task_logger.log "Domain WHOIS failed, we don't know what nameserver to query."
  end
  
end

def cleanup
  super
end
