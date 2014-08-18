#!/usr/bin/env ruby

###
### This example shows you how to create an entity and run a task on it.
### 

puts "[+] Setting Tenant"
Tenant.current = Tenant.first  		# Tenant.find_by :name => "jcran.intrigue.io"

puts "[+] Setting Project"
Project.current = Project.first 	# Project.find_by :name => "yahoo"

entity_name = "http:/www.yahoo.com"
puts "[+] Running task... #{entity_name} "
entity = Entities::WebApplication.create :name => entity_names

task_name = "gather_ssl_certificate"
puts "[+] Running task... #{task_name} "
entity.run_task task_name, TaskRunSet.create ,{}