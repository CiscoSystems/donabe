class NetworkDesign < ActiveRecord::Base
  attr_accessible :name, :read, :body, :types_attributes, :routers_attributes, :subnets_attributes, :vms_attributes, :embedded_containers_attributes

  has_many :types, :dependent => :destroy
  has_many :routers, :dependent => :destroy
  has_many :subnets, :dependent => :destroy
  has_many :vms, :dependent => :destroy
  has_many :embedded_containers, :dependent => :destroy

  accepts_nested_attributes_for :types, :allow_destroy => true
  accepts_nested_attributes_for :routers, :allow_destroy => true
  accepts_nested_attributes_for :subnets, :allow_destroy => true
  accepts_nested_attributes_for :vms, :allow_destroy => true
  accepts_nested_attributes_for :embedded_containers, :allow_destroy => true
  
  after_initialize :init

  def init
    self.read = false
  end
end
