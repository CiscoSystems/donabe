class ConnectedEndpoint < ActiveRecord::Base
  belongs_to :embedded_container
  attr_accessible :connected_id, :endpoint_id
end
