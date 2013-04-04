class DeployedContainersController < ApplicationController

  # GET :tenant_id/deployed_container/:id.json
  # Get a JSON representation of the given deployed container
  def show
    @deployed_container = DeployedContainer.where(:tenant_id => params[:tenant_id], :id => params[:id])
  end

  # GET :tenant_id/deployed_containers.json
  # Get a JSON representation of all deployed containers belonging to the given tenant
  def index
    @deployed_containers = DeployedContainer.where(:tenant_id => params[:tenant_id])
  end

  # PUT :tenant_id/deployed_containers.json
  # NOT YET IMPLEMENTED
  def update
    @updated_container = params([:container])
    @container = DeployedContainer.find(params[:container][:id])

    nova_ip = nil
    quantum_ip = nil
    if request.headers["X-Auth-Token"] != ""
      token = request.headers["X-Auth-Token"]
      begin
        services = Donabe::KEYSTONE.get_endpoints(token)
        services["endpoints"].each do |endpoint|
          if endpoint["name"] == "nova"
            nova_ip = endpoint["internalURL"]
          elsif endpoint["name"]  == "quantum"
            quantum_ip = endpoint["internalURL"]
          end
        end
      rescue
        token = Storage.find(cookies[:current_token]).data
        nova_ip = Storage.find(cookies[:nova_ip]).data
        quantum_ip = Storage.find(cookies[:quantum_ip]).data
      end
    end

    novaIP = URI.parse(nova_ip)
    nova =  Ropenstack::Nova.new(novaIP, token)

    quantumIP = URI.parse(quantum_ip)
    quantum = Ropenstack::Quantum.new(quantumIP, token)

    # Make a note of how many networks this container already has
    networks_count = @container.deployed_networks.count
    # Define an array to keep track of how many existing networks have been sent back
    existing_networks = Array.new()
    @updated_container["deployed_networks"].each do |network|
      if network["deployStatus"] == false
        # This is a new network. Create it and store its data

      else
        # This is an existing network
        existing_networks << network["temp_id"]
      end
    end
   
    if existing_networks.count < networks_count
      # Some existing networks were not sent back. Delete these networks
    end 

    # Make a note of how many VMs this container already has
    vms_count = @container.deployed_vms.count
    # Define an array to keep track of how many existing VMs have been sent back
    existing_vms = Array.new()
    @updated_container["deployed_vms"].each do |vm|
      if vm["deployStatus"] == false
        # This is a new VM. Create it and store its data
        v = @container.deployed_vms.build()
        ports = Array.new()
        port_list = Array.new()
        vm["deployed_connected_networks"].each do |network|
          port = quantum.create_port(network["openstack_id"],'',"compute:nova")
          ports << port["port"]["id"]
          data = {'uuid'=>network["openstack_id"]}
          port_list << data
          connected_network = v.deployed_connected_networks.build()
          connected_network.openstack_id = network["openstack_id"]
          connected_network.save  
        end
      else
        # This is an existing VM
        existing_vms << vm["temp_id"]
      end
    end
    
    if existing_vms.count < vms_count
      # Some existing vms were not sent back. Delete these vms
    end 
    
    # Make a note of how many routers this container already has
    routers_count = @container.deployed_routers.count
    # Define an array to keep track of how many existing routers have been sent back
    existing_routers = Array.new()
    @updated_container["deployed_routers"].each do |router|
      if router["deployStatus"] == false
        # This is a new router. Create it and store its data
      else
        # This is an existing router
        existing_routers << router["temp_id"] 
      end
    end

    if existing_routers.count < routers_count
      # Some existing routers were not sent back. Delete these routers
    end 

    @updated_container["deployed_conatiners"].each do |container|
      # Do some magic. Possibly recursive magic.
    end

  end

end
