# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'securerandom'

puts "Removing Reports"
ReportTemplate.all.each {|x| x.destroy }

puts "Seeding Reports"

ReportTemplate.create( 
  :name => "all", 
  :pretty_name => "All Entities List",
  :template => "list",
  :setup => "@entities = Entities::Base.all")

ReportTemplate.create( 
  :name => "findings", 
  :pretty_name => "Findings List",
  :template => "list",
  :setup => "@entities = Entities::Finding.all")

ReportTemplate.create( 
  :name => "children",
  :pretty_name => "Children", 
  :template => "show_children",
  :setup => "@entities = Entities::Base.all")

ReportTemplate.create( 
  :name => "parents",
  :pretty_name => "Parents", 
  :template => "show_parents",
  :setup => "@entities = Entities::Base.all")

#ReportTemplate.create( 
#  :name => "peeping_tom", 
#  :pretty_name => "Peeping Tom", 
#  :template => "peeping_tom",
#  :setup => "@entities = Entities::LocalImage.all")

ReportTemplate.create( 
  :name => "physical_locations",
  :pretty_name => "Physical Location Listing", 
  :template => "physical_locations",
  :setup => "@entities = Entities::PhysicalLocation.all")

Tenant.each do |t|
  # Set the current tenant, so the user is saved correctly (it's tenant-scoped)
  Tenant.current = t

  # Check to see if we have any users available for this tenant
  if User.count == 0
    puts "Could not find a user for tenant #{t.host}"

    # generate a password
    account_password = SecureRandom.hex(6)

    if t.host == "localhost"
      user = User.create!( 
        :name => "user", 
        :email => "user@localhost.local",
        :password => account_password,  
        :password_confirmation => account_password)
      puts "Created user #{user.email} for tenant #{t.host} with password #{account_password}"
    else
      ### 
      ### Calculate the name and create a user account
      ###
      account_domain = t.host
      account_domain = account_domain.split(".")
      account_domain.shift #drop the subdomain 
      account_domain = account_domain.join(".")

      account_name = "#{t.host.split(".").first}"
      account_email = "#{account_name}@#{account_domain}"

      user = User.create!( 
        :name => account_name, 
        :email => account_email,
        :password => account_password,  
        :password_confirmation => account_password)
      puts "Created user #{user.email} for tenant #{t.host} with password #{account_password}"
    end
  else
    puts "User exists for tenant #{t.host}"
  end
end
