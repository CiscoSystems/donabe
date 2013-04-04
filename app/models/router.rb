class Router < ActiveRecord::Base
  belongs_to :container
  attr_accessible :name, :endpoint, :temp_id, :connected_networks_attributes
 
  has_many :connected_networks, :dependent => :destroy

  accepts_nested_attributes_for :connected_networks, :allow_destroy => true
end
