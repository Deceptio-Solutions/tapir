module Entities
  class ParsableText < Base
    
    include TenantAndProjectScoped

    field :text, type: String

  end
end