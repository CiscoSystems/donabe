class DeployedVm < ActiveRecord::Base
  belongs_to :deployed_container
  attr_accessible :openstack_id, :image_id, :image_name, :name, :temp_id, :flavor, :endpoint, :deployed_connected_networks_attributes, :ports_attributes
  
  has_many :deployed_connected_networks, :dependent => :destroy
  has_many :ports, :dependent => :destroy

  accepts_nested_attributes_for :deployed_connected_networks, :allow_destroy => true
  accepts_nested_attributes_for :ports, :allow_destroy => true
end
