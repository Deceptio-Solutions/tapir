
module Entities
  class WebPage < Base
    include TenantAndProjectScoped

    field :uri, type: String
    field :content, type: String

    belongs_to :web_application, :class_name => "Tapir::Entities::WebApplication"

  end
end