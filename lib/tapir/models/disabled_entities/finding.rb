
module Entities
  class Finding < Base
    include TenantAndProjectScoped

    field :content, type: String
    field :details, type: String

    validates_uniqueness_of :content, :scope => [:tenant_id,:project_id]
  end
end
