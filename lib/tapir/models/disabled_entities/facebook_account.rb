module Entities
  class FacebookAccount < Base 
    include TenantAndProjectScoped
    field :uri, type: String
  end
end