
module Entities
  class SearchString < Base
    include TenantAndProjectScoped

    field :description, type: String

  end
end