
module Entities
  class DnsRecord < Base      
    include TenantAndProjectScoped

    field :record_type

    field :record_created_on, type: Time
    field :record_updated_on, type: Time
    field :record_expires_on, type: Time

    field :disclaimer, type: String 
    field :registrar_name, type: String
    field :registrar_org, type: String
    field :registrar_url, type: String
    field :referral_whois, type: String
    field :registered, type: String
    field :available, type: String
    
    field :full_text, type: String

    #validates_presence_of :name, :scope => [:tenant_id,:project_id]
    #validates_uniqueness_of :name, :scope => [:tenant_id,:project_id]

    # Make sure to allow for wildcards names! :)
    validates :name, 
      :presence => true, 
      :uniqueness => {:scope => [:tenant_id,:project_id]},
      :format => { 
        :with => Regexp.new(/^[A-Za-z0-9\.\*\-]+$/),
        :message => "Not a valid hostname"
      }

    belongs_to :host, :class_name => "Entities::Host"

  end
end