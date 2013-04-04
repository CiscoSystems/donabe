class Container < ActiveRecord::Base
  attr_accessible :name, :body, :read, :tenant_id, :types_attributes, :networks_attributes, :routers_attributes, :vms_attributes, :embedded_containers_attributes, :endpoints_attributes

  has_many :types, :dependent => :destroy
  has_many :routers, :dependent => :destroy
  has_many :networks, :dependent => :destroy
  has_many :vms, :dependent => :destroy
  has_many :embedded_containers, :dependent => :destroy
  has_many :endpoints, :dependent => :destroy

  accepts_nested_attributes_for :types, :allow_destroy => true
  accepts_nested_attributes_for :routers, :allow_destroy => true
  accepts_nested_attributes_for :networks, :allow_destroy => true
  accepts_nested_attributes_for :vms, :allow_destroy => true
  accepts_nested_attributes_for :embedded_containers, :allow_destroy => true
  accepts_nested_attributes_for :endpoints, :allow_destroy => true

  after_initialize :init

  def init
    self.read = false
  end
end
