#!/usr/bin/env ruby
require "#{File.join(File.dirname(__FILE__), "..", "config", "environment")}"

# Set the current tenant - this is required because
# all entities must be scoped according to the tenant
Tenant.current = Tenant.all.first
Project.current = Project.all.first

# open up a list of domains
f = File.open(ARGV[0], "r")

puts "Running..."
f.each do |line| 
  begin 
    h = Entities::Host.create(
      :name => line.strip,
      :tenant_id => Tenant.current.id,
      :project_id =>Project.current.id)
    h.run_task "whois", {}
    h.run_task "geolocate_host", {}

  rescue Exception => e
    puts "ohnoes! #{e}"
  end
end
