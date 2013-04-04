class DeployedRouter < ActiveRecord::Base
  belongs_to :deployed_container
  attr_accessible :openstack_id, :temp_id, :endpoint, :deployed_connected_networks_attributes

  has_many :deployed_connected_networks, :dependent => :destroy

  accepts_nested_attributes_for :deployed_connected_networks, :allow_destroy => true
end
