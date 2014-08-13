
module Entities
  class Host < Base
    include TenantAndProjectScoped

    has_many :net_svcs
    has_many :dns_records
    
    validates :name, 
      :uniqueness => {:scope => [:tenant_id,:project_id]},
      :format => { 
        :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex),
        :message => "Not an valid IPv4 or IPv6 format"
      }

  end
end