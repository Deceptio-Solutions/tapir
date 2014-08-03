
module Entities
  class ParsableFile < Base
    
    include TenantAndProjectScoped

    field :uri, type: String

  end
end