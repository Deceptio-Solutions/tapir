
module Entities
  class Person < Base
    include TenantAndProjectScoped

    has_many :email_addresses
    accepts_nested_attributes_for :email_addresses, :allow_destroy => true
    
    has_many :usernames
    accepts_nested_attributes_for :usernames, :allow_destroy => true

  end
end