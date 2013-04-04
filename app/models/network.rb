class Network < ActiveRecord::Base
  attr_accessible :name, :cidr, :temp_id, :endpoint

  belongs_to :container
end
