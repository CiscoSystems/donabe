class ConnectedNetwork < ActiveRecord::Base
  belongs_to :vm
  attr_accessible :temp_id
end
