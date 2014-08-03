
module Entities
  class Organization < Base
    include TenantAndProjectScoped

    field :description, type: String

  end
end