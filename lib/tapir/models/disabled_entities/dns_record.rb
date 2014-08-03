
module Entities
  class DnsRecord < Base      
    include TenantAndProjectScoped

    neoidable do |c|
      c.field :record_type
      c.field :record_created_on, type: Time
      c.field :record_updated_on, type: Time
      c.field :record_expires_on, type: Time
      c.field :disclaimer, type: String 
      c.field :registrar_name, type: String
      c.field :registrar_org, type: String
      c.field :registrar_url, type: String
      c.field :referral_whois, type: String
      c.field :registered, type: String
      c.field :available, type: String
      c.field :full_text, type: String
    end

    #validates_presence_of :name, :scope => [:tenant_id,:project_id]
    #validates_uniqueness_of :name, :scope => [:tenant_id,:project_id]

    # Make sure to allow for wildcards names! :)
    validates :name, 
      :presence => true, 
      :uniqueness => {:scope => [:tenant_id,:project_id]},
      :format => { 
        :with => Regexp.new(/^[A-Za-z0-9\.\*]+$/),
        :message => "Not a valid hostname"
      }

    belongs_to :host, :class_name => "Entities::Host"

  end
end