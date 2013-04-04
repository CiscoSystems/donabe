class DeployedConnectedNetwork < ActiveRecord::Base
  belongs_to :deployed_vm
  attr_accessible :openstack_id
end
