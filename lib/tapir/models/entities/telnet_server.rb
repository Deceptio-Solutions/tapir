module Entities
  class TelnetServer < Base
    include TenantAndProjectScoped

    belongs_to :host

    validates :name, 
      :uniqueness => {:scope => [:tenant_id,:project_id]},
      :format => { 
        :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex),
        :message => "Not an valid IPv4 or IPv6 format"
      }

  end
end