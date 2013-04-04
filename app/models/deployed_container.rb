class DeployedContainer < ActiveRecord::Base
  attr_accessible :container_id, :tenant_id, :deployed_routers_attributes, :deployed_networks_attributes, :deployed_vms_attributes

  validates :container_id, :presence => true

  has_many :deployed_routers, :dependent => :destroy
  has_many :deployed_networks, :dependent => :destroy
  has_many :deployed_vms, :dependent => :destroy
  has_many :deployed_containers, :dependent => :destroy

  accepts_nested_attributes_for :deployed_routers, :allow_destroy => true
  accepts_nested_attributes_for :deployed_networks, :allow_destroy => true
  accepts_nested_attributes_for :deployed_vms, :allow_destroy => true
  accepts_nested_attributes_for :deployed_containers, :allow_destroy => true
end
