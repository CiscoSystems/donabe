json.(@container, :name, :id)
json.routers @container.routers.each do |json, router|
  json.(router, :name, :temp_id, :endpoint)
  json.networks router.connected_networks.each do |network|
    json.(network, :temp_id)
  end
end
json.networks @container.networks.each do |json, network|
  json.(network, :name, :temp_id, :endpoint, :cidr)
end
json.vms @container.vms.each do |json, vm|
  json.(vm, :temp_id, :name, :image_id, :image_name, :flavor, :endpoint)
  json.networks vm.connected_networks.each do |json, network|
    json.(network, :temp_id)
  end
end
json.containers @container.embedded_@containers.each do |json, embedded_@container|
  json.(embedded_container, :embedded_container_id)
  json.endpoints embedded_container.connected_endpoints.each do |json, endpoint|
    json.(endpoint, :endpoint_id, :connected_id)
  end
end
