module Entities
  class LinkedinAccount < Base 
    include TenantAndProjectScoped
    field :uri, type: String
  end
end