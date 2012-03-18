# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111217213719) do

  create_table "accounts", :force => true do |t|
    t.string   "account_name"
    t.string   "service_name"
    t.string   "web_uri"
    t.string   "check_uri"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.date     "record_created_on"
    t.date     "record_updated_on"
    t.date     "record_expires_on"
    t.string   "disclaimer"
    t.string   "registrar_name"
    t.string   "registrar_org"
    t.string   "registrar_url"
    t.string   "referral_whois"
    t.boolean  "registered"
    t.boolean  "available"
    t.integer  "organization_id"
    t.integer  "host_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "findings", :force => true do |t|
    t.string   "name"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hosts", :force => true do |t|
    t.string   "ip_address"
    t.integer  "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "local_path"
    t.string   "remote_path"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "net_blocks", :force => true do |t|
    t.integer  "domain_id"
    t.string   "range"
    t.string   "handle"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "net_svcs", :force => true do |t|
    t.string   "name"
    t.integer  "host_id"
    t.string   "fingerprint"
    t.string   "proto"
    t.integer  "port_num"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "object_mappings", :force => true do |t|
    t.integer  "child_id"
    t.string   "child_type"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "task_run_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "email_schemas"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_locations", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.string   "latitude"
    t.string   "longitude"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "host_id"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_strings", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_runs", :force => true do |t|
    t.string   "task_name"
    t.integer  "task_object_id"
    t.string   "task_object_type"
    t.text     "task_options_hash"
    t.text     "task_log"
    t.integer  "organization_id"
    t.integer  "physical_location_id"
    t.integer  "user_id"
    t.integer  "domain_id"
    t.integer  "host_id"
    t.integer  "net_svc_id"
    t.integer  "web_app_id"
    t.integer  "web_form_id"
    t.integer  "image_id"
    t.integer  "account_id"
    t.integer  "net_block_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.text     "email_addresses"
    t.text     "usernames"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "web_apps", :force => true do |t|
    t.integer  "net_svc_id"
    t.string   "name"
    t.string   "url"
    t.string   "fingerprint"
    t.text     "description"
    t.string   "techology"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "web_forms", :force => true do |t|
    t.integer  "metric"
    t.integer  "web_app_id"
    t.string   "name"
    t.string   "url"
    t.string   "action"
    t.text     "fields"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
