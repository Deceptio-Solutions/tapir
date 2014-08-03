
module Entities
  class NetSvc < Base
    include TenantAndProjectScoped

    field :fingerprint, type: String
    field :proto, type: String
    field :port_num, type: Integer

    belongs_to :host, :class_name => "Entities::Host"
  end
end