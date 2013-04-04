class ConnectedVm < ActiveRecord::Base
  belongs_to :embedded_container
  attr_accessible :temp_id
end
