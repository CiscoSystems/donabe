class Port < ActiveRecord::Base
  belongs_to :deployed_vm
  attr_accessible :port_id
end
