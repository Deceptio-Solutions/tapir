
module Entities
  class PhysicalLocation < Base
    include TenantAndProjectScoped

    field :address, type: String
    field :city, type: String
    field :state, type: String
    field :country, type: String
    field :zip, type: String
    field :latitude, type: String
    field :longitude, type: String

  end
end