class DeployedConnectedNetwork < ActiveRecord::Base
  belongs_to :deployed_vm
  belongs_to :deployed_router
  attr_accessible :openstack_id, :default_subnet
end
