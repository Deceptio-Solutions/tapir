
module Entities
  class NetBlock < Base
    include TenantAndProjectScoped

    field :start_address, type: String 
    field :end_address, type: String 
    field :cidr, type: String
    field :block_type, type: String
    field :description, type: String
    field :handle, type: String
    field :org_ref, type: String
    field :parent_ref, type: String

    validates :start_address, 
      :presence => true, 
      :format => { 
        :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex),
        :message => "Not an valid IPv4 or IPv6 range"
      }

    validates :end_address, 
      :presence => true, 
      :format => { 
        :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex),
        :message => "Not an valid IPv4 or IPv6 range"
      }

    validates :cidr, 
      :presence => true, 
      :format => { 
        :with => Regexp.new(/\d{1,2}/),
        :message => "Not an valid IPv4 or IPv6 range"
      }

    def range
      "#{start_address}/#{cidr}"
    end

  end
end