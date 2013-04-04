class Vm < ActiveRecord::Base
  belongs_to :container
  belongs_to :network_design
  attr_accessible :image_id, :image_name, :temp_id, :name, :flavor, :endpoint, :connected_networks_attributes

  has_many :connected_networks, :dependent => :destroy

  accepts_nested_attributes_for :connected_networks, :allow_destroy => true
end
