module Entities
  class TwitterAccount < Base
    include TenantAndProjectScoped
    field :uri, type: String
  end
end