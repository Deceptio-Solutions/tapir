require 'resolv'

##
## Thanks to @darkoperator for the tld records
##

def name
  "dns_tld_brute"
end

def pretty_name
  "DNS TLD Brute"
end

def authors
  ['jcran']
end

# Returns a string which describes what this task does
def description
  "Bruteforce the top-level domains (TLDs) for a given entity"
end

# Returns an array of valid types for this task
def allowed_types
  [ Entities::DnsRecord, 
    Entities::SearchString, 
    Entities::Organization]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
  self
end

## Default method, subclasses must override this
def run
  super

  # Find more info here: http://www.icann.org/en/tlds/

  # @chrisjohnriley passed along this:https://mxr.mozilla.org/mozilla-central/source/netwerk/dns/effective_tld_names.dat?raw=1 

=begin
  if @options['cctld_list']
    cctld_list = @options['cctld_list']
  else
    cctld_list = ['ac', 'ad', 'ae', 'af', 'ag', 'ai', 'al', 'am', 'an', 'ao', 'aq', 'ar',
    'as', 'at', 'au', 'aw', 'ax', 'az', 'ba', 'bb', 'bd', 'be', 'bf', 'bg',
    'bh', 'bi', 'bj', 'bm', 'bn', 'bo', 'br', 'bs', 'bt', 'bv', 'bw', 'by', 'bzca',
    'cat', 'cc', 'cd', 'cf', 'cg', 'ch', 'ci', 'ck', 'cl', 'cm', 'cn', 'co',
    'cr', 'cu', 'cv', 'cx', 'cy', 'cz', 'de', 'dj', 'dk', 'dm', 'do', 'dz', 'ec', 'ee',
    'eg', 'er', 'es', 'et', 'eu', 'fi', 'fj', 'fk', 'fm', 'fo', 'fr', 'ga', 'gb', 'gd', 'ge',
    'gf', 'gg', 'gh', 'gi', 'gl', 'gm', 'gn', 'gp', 'gq', 'gr', 'gs', 'gt', 'gu', 'gw',
    'gy', 'hk', 'hm', 'hn', 'hr', 'ht', 'hu', 'id', 'ie', 'il', 'im', 'in', 
    'io', 'iq', 'ir', 'is', 'it', 'je', 'jm', 'jo', 'jp', 'ke', 'kg', 'kh', 'ki', 'km',
    'kn', 'kp', 'kr', 'kw', 'ky', 'kz', 'la', 'lb', 'lc', 'li', 'lk', 'lr', 'ls', 'lt', 'lu',
    'lv', 'ly', 'ma', 'mc', 'md', 'me', 'mg', 'mh', 'mk', 'ml', 'mm', 'mn', 'mo',
    'mp', 'mq', 'mr', 'ms', 'mt', 'mu', 'mv', 'mw', 'mx', 'my', 'mz', 'na',
    'nc', 'ne', 'nf', 'ng', 'ni', 'nl', 'no', 'np', 'nr', 'nu', 'nz', 'om',
    'pa', 'pe', 'pf', 'pg', 'ph', 'pk', 'pl', 'pm', 'pn', 'pr', 'pro', 'ps', 'pt', 'pw',
    'py', 'qa', 're', 'ro', 'rs', 'ru', 'rw', 'sa', 'sb', 'sc', 'sd', 'se', 'sg', 'sh', 'si',
    'sj', 'sk', 'sl', 'sm', 'sn', 'so', 'sr', 'st', 'su', 'sv', 'sy', 'sz', 'tc', 'td', 'tel',
    'tf', 'tg', 'th', 'tj', 'tk', 'tl', 'tm', 'tn', 'to', 'tp', 'tr', 'tt', 'tv',
    'tw', 'tz', 'ua', 'ug', 'uk', 'us', 'uy', 'uz', 'va', 'vc', 've', 'vg', 'vi', 'vn', 'vu',
    'wf', 'ws', 'xxx', 'ye', 'yt', 'za', 'zm', 'zw']
  end
=end

  if @options['gtld_list']
    gtld_list = @options['gtld_list']
  else
    gtld_list = ['co', 'co.uk', 'com' ,'net', 'biz', 'org', 'int', 'mil', 'edu',
    'biz', 'info', 'name', 'pro', 'aero', 'coop', 'museum', 'asia', 'cat', 'jobs',
    'mobi', 'tel', 'travel', 'arpa', 'gov', "us", "cn", "to", "xxx", "io"]
  end

  @task_logger.log "Using gtld list: #{gtld_list}"

    resolved_addresses = []

    gtld_list.each do |tld|
      begin

        if @entity.class == Entities::DnsRecord
          # get only the basename
          basename = @entity.name.split(".")[0..-2].join(".").gsub(" ","")
        else
          basename = @entity.name.gsub(" ", "")
        end
        
        # Calculate the domain name
        domain = "#{basename}.#{tld}"

        # Try to resolve
        resolved_address = Resolv.new.getaddress(domain)
        @task_logger.good "Resolved Address #{resolved_address} for #{domain}" if resolved_address

        # If we resolved, create the right entitys
        if resolved_address
          @task_logger.good "Creating domain and host entities..."
          d = create_entity(Entities::DnsRecord, {:name => domain})
          h = create_entity(Entities::Host, {:name => resolved_address})
        end

        #@task_run.save_raw_result "#{domain}: resolved_address"

      rescue Exception => e
        @task_logger.error "Hit exception: #{e}"
      end

   
    end
end
