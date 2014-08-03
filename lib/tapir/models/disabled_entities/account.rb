module Entities
  class Account < Base
    include TenantAndProjectScoped

    neoidable do |c|
      c.field :account_name, type: String
      c.field :service_name, type: String
      c.field :uri, type: String
      c.field :check_uri, type: String
    end

    def to_s
      super << " #{service_name} #{account_name}"
    end

    def name
      "#{account_name}"
    end

  end
end
