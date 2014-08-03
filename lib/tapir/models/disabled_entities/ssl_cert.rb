module Entities
  class SslCert < Base
    include TenantAndProjectScoped

    field :text, type: String

  end
end