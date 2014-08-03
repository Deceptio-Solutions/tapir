module Entities
  class KloutAccount < Base 
    include TenantAndProjectScoped
    field :uri, type: String
  end
end