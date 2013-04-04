class DeployedNetwork < ActiveRecord::Base
  belongs_to :deployed_container
  attr_accessible :openstack_id, :cidr, :default_subnet, :temp_id, :endpoint
end
