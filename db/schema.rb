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

ActiveRecord::Schema.define(:version => 20130304220548) do

  create_table "connected_endpoints", :force => true do |t|
    t.string   "endpoint_id"
    t.string   "connected_id"
    t.integer  "embedded_container_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "connected_endpoints", ["embedded_container_id"], :name => "index_connected_endpoints_on_embedded_container_id"

  create_table "connected_networks", :force => true do |t|
    t.string   "temp_id"
    t.integer  "vm_id"
    t.integer  "router_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "connected_networks", ["router_id"], :name => "index_connected_networks_on_router_id"
  add_index "connected_networks", ["vm_id"], :name => "index_connected_networks_on_vm_id"

  create_table "connected_routers", :force => true do |t|
    t.string   "temp_id"
    t.integer  "network_id"
    t.integer  "embedded_container_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "connected_routers", ["embedded_container_id"], :name => "index_connected_routers_on_embedded_container_id"
  add_index "connected_routers", ["network_id"], :name => "index_connected_routers_on_network_id"

  create_table "connected_vms", :force => true do |t|
    t.string   "temp_id"
    t.integer  "embedded_container_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "connected_vms", ["embedded_container_id"], :name => "index_connected_vms_on_embedded_container_id"

  create_table "containers", :force => true do |t|
    t.string   "name"
    t.string   "body"
    t.boolean  "read"
    t.string   "tenant_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "deployed_connected_networks", :force => true do |t|
    t.string   "openstack_id"
    t.string   "default_subnet"
    t.integer  "deployed_vm_id"
    t.integer  "deployed_router_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "deployed_connected_networks", ["deployed_router_id"], :name => "index_deployed_connected_networks_on_deployed_router_id"
  add_index "deployed_connected_networks", ["deployed_vm_id"], :name => "index_deployed_connected_networks_on_deployed_vm_id"

  create_table "deployed_containers", :force => true do |t|
    t.integer  "container_id"
    t.string   "tenant_id"
    t.string   "name"
    t.integer  "deployed_container_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "deployed_containers", ["deployed_container_id"], :name => "index_deployed_containers_on_deployed_container_id"

  create_table "deployed_networks", :force => true do |t|
    t.string   "openstack_id"
    t.string   "cidr"
    t.string   "default_subnet"
    t.string   "temp_id"
    t.boolean  "endpoint"
    t.integer  "deployed_container_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "deployed_networks", ["deployed_container_id"], :name => "index_deployed_networks_on_deployed_container_id"

  create_table "deployed_routers", :force => true do |t|
    t.string   "openstack_id"
    t.string   "temp_id"
    t.boolean  "endpoint"
    t.integer  "deployed_container_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "deployed_routers", ["deployed_container_id"], :name => "index_deployed_routers_on_deployed_container_id"

  create_table "deployed_vms", :force => true do |t|
    t.string   "openstack_id"
    t.string   "image_name"
    t.string   "image_id"
    t.string   "name"
    t.string   "temp_id"
    t.string   "flavor"
    t.boolean  "endpoint"
    t.integer  "deployed_container_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "deployed_vms", ["deployed_container_id"], :name => "index_deployed_vms_on_deployed_container_id"

  create_table "embedded_containers", :force => true do |t|
    t.string   "embedded_container_id"
    t.boolean  "endpoint"
    t.integer  "container_id"
    t.integer  "network_design_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "embedded_containers", ["container_id"], :name => "index_embedded_containers_on_container_id"
  add_index "embedded_containers", ["network_design_id"], :name => "index_embedded_containers_on_network_design_id"

  create_table "endpoints", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "endpoint_id"
    t.integer  "container_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "endpoints", ["container_id"], :name => "index_endpoints_on_container_id"

  create_table "flavors", :force => true do |t|
    t.string   "name"
    t.integer  "uuid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "images", :force => true do |t|
    t.string   "name"
    t.string   "uuid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "network_designs", :force => true do |t|
    t.string   "name"
    t.boolean  "read"
    t.string   "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "networks", :force => true do |t|
    t.string   "name"
    t.string   "cidr"
    t.string   "temp_id"
    t.boolean  "endpoint"
    t.integer  "container_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "networks", ["container_id"], :name => "index_networks_on_container_id"

  create_table "ports", :force => true do |t|
    t.string   "port_id"
    t.integer  "deployed_vm_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "ports", ["deployed_vm_id"], :name => "index_ports_on_deployed_vm_id"

  create_table "routers", :force => true do |t|
    t.string   "name"
    t.string   "temp_id"
    t.boolean  "endpoint"
    t.integer  "container_id"
    t.integer  "network_design_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "routers", ["container_id"], :name => "index_routers_on_container_id"

  create_table "storages", :force => true do |t|
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "types", :force => true do |t|
    t.string   "name"
    t.string   "image"
    t.string   "flavor"
    t.integer  "container_id"
    t.integer  "network_design_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "types", ["container_id"], :name => "index_types_on_container_id"
  add_index "types", ["network_design_id"], :name => "index_types_on_network_design_id"

  create_table "vms", :force => true do |t|
    t.string   "image_name"
    t.string   "image_id"
    t.string   "name"
    t.string   "temp_id"
    t.string   "flavor"
    t.boolean  "endpoint"
    t.integer  "container_id"
    t.integer  "network_design_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "vms", ["container_id"], :name => "index_vms_on_container_id"
  add_index "vms", ["network_design_id"], :name => "index_vms_on_network_design_id"

end
