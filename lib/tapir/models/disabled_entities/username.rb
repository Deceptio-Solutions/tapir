module Entities
  class Username < Base
    include TenantAndProjectScoped

    belongs_to :person, :class_name => "Entities::Person"

  end
end