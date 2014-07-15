module Entities
  class WebApplicationHeader < Base
    include TenantAndProjectScoped

    field :content, type: String
    
    belongs_to :web_application, :class_name => "Entities::WebApplication"

  end
end