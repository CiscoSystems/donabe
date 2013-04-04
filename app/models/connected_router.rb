class ConnectedRouter < ActiveRecord::Base
  belongs_to :network
  belongs_to :embedded_container
  attr_accessible :temp_id
end
