class Type < ActiveRecord::Base
  belongs_to :container
  belongs_to :network_design
  attr_accessible :flavor, :image, :name
end
