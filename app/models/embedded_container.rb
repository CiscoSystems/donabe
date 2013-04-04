class EmbeddedContainer < ActiveRecord::Base
  belongs_to :container
  belongs_to :network_design
  attr_accessible :embedded_container_id, :endpoint, :connected_endpoints_attributes

  has_many :connected_endpoints, :dependent => :destroy

  accepts_nested_attributes_for :connected_endpoints, :allow_destroy => true
end
