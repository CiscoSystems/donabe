json.container do |json|
  json.(@deployed_container, :id, :container_id, :tenant_id)
  json.routers @deployed_container.deployed_routers.each do |json, router|
    json.(router, :temp_id, :openstack_id, :endpoint)
  end
  json.networks @deployed_container.deployed_networks.each do |json, network|
    json.(network, :temp_id, :openstack_id, :cidr, :endpoint)
  end
  json.vms @deployed_container.deployed_vms.each do |json, vm|
    json.(vm, :temp_id, :openstack_id, :name, :image_id, :image_name, :flavor, :endpoint)
  end
  json.containers @deployed_container.deployed_containers.each do |json, container|
    json.(container, :id)
  end
end
