module Entities
  class PhoneNumber < Base
    include TenantAndProjectScoped
  end
end