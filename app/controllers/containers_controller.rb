=begin
	* Name: ContainersController
	* Description: Contains all functions for creation/modification/deployment of containers
	* Author: John Davidge
	* Date: 09/04/2013
=end

require 'json'
require 'net/http'
require 'uri'

class ContainersController < ApplicationController
  # GET :tenant_id/container/:id.json
  # Get a JSON representation of the given container
  def show
    @container = Container.where(:tenant_id => params[:tenant_id], :id => params[:id])
  end
 
  # GET :tenant_id/containers.json
  # Get a JSON representation of all containers belonging to the given tenant
  def index
    @containers = Container.where(:tenant_id => params[:tenant_id])
    logger.info "Containers:"
    logger.info @containers.to_s()
  end

  # Called by the 'create' function
  # Takes a JSON representation of a container and builds the appropriate database entries
  def create_from_JSON(container)
    @container = container

    # Read the JSON and create the container framework
    @body = @container.body
    @body = JSON.parse(@body)

    @container.name = @body["name"]

    @body["routers"].each do |r|
      router = @container.routers.build()
      router.name = r["name"]
      router.temp_id = r["temp_id"]
      r["networks"].each do |s|
        network = router.connected_networks.build()
        network.temp_id = s["temp_id"]
        network.save
      end
      if r["endpoint"] == true
        endpoint = @container.endpoints.build()
        endpoint.endpoint_id = router.id
        endpoint.name = router.name
        endpoint.type = "router"
        endpoint.save
        router.endpoint = true
      else
        router.endpoint = false
      end
      router.save
    end

    @body["networks"].each do |s|
      network = @container.networks.build()
      network.name = s["name"]
      network.temp_id = s["temp_id"]
      network.cidr = s["cidr"]
      if s["endpoint"] == true
        endpoint = @container.endpoints.build()
        endpoint.endpoint_id = network.id
        endpoint.name = network.name
        endpoint.type = "network"
        endpoint.save
        network.endpoint = true
      else
        network.endpoint = false
      end
      network.save
    end

    @body["vms"].each do |v|
      vm = @container.vms.build()
      vm.temp_id = v["temp_id"]
      vm.name = v["name"]
      vm.image_name = v["image_name"]
      vm.image_id = v["image_id"]
      vm.flavor = v["flavor"]
      v["networks"].each do |s|
        network = vm.connected_networks.build()
        network.temp_id = s["temp_id"]
        network.save
      end
      if v["endpoint"] == true
        endpoint = @container.endpoints.build()
        endpoint.endpoint_id = vm.id
        endpoint.name = vm.name
        endpoint.type = "vm"
        endpoint.save
        vm.endpoint = true
      else
        vm.endpoint = false
      end
      vm.save
    end

    @body["containers"].each do |c|
      embedded_container = @container.embedded_containers.build()
      embedded_container.embedded_container_id = c["embedded_container_id"]
      c["endpoints"].each do |e|
        endpoint = embedded_container.connected_endpoints.build()
        endpoint.endpoint_id = e["endpoint_id"]
        endpoint.connected_id = e["connected_id"]
        endpoint.save
      end
      embedded_container.save
    end

    @container.save

  end
 
  # PUT :tenant_id/containers/:id.json
  # Update an exisiting container to add/remove/change nodes
  # Permanently changes the given container - all containers which reference this container
  # will be affected
  def update
    @container = Container.find(params[:id])

    # Destroy everything in the container but not the container itself    
    @container.routers.each do |router|
      router.destroy()
    end
    @container.networks.each do |network|
      network.destroy()
    end
    @container.vms.each do |vm|
      vm.destroy()
    end
    @container.embedded_containers.each do |container|
      container.destroy()
    end

    # Save the JSON representation of the new state
    @container.body = JSON.dump(params)
   
    respond_to do |format|
      if @container.save
        create_from_JSON(@container)
        format.html { render :file => "containers/show.json.erb" }
        format.json { render :json => @container }
      else
        format.html { render :json => @container.errors, :status => :unprocessable_entity }
        format.json { render :json => @container.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST :tenant_id/containers.json
  # Create a new container from a given JSON representation
  def create
    @container = Container.new(params[:container])

    @container.tenant_id = params[:tenant_id]
    @container.body = JSON.dump(params)
   
    respond_to do |format|
      if @container.save
        create_from_JSON(@container)
        format.html { render :file => "containers/show.json.erb" }
        format.json { render :json => @container }
      else
        format.html { render :json => @container.errors, :status => :unprocessable_entity }
        format.json { render :json => @container.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET :tenant_id/containers/deploy/:id.json
  # Deploy the given container into the given tenant
  # Makes use of the 'deployHelper' function to enable recursive deployment
  def deploy
    @deployed_container = DeployedContainer.new()

    nova_ip = nil
    quantum_ip = nil

    # Check for auth token in HTTP request
    if request.headers["X-Auth-Token"] != ""
      logger.info "Token not blank"
      token = request.headers["X-Auth-Token"]
      logger.info "Token:"
      logger.info token
      begin
        # Define OpenStack endpoint URLs
        services = Donabe::KEYSTONE.get_endpoints(token)
        logger.info "SERVICES:"
        logger.info services
        services["endpoints"].each do |endpoint|
          if endpoint["name"] == "nova"
            nova_ip = endpoint["internalURL"]
          elsif endpoint["name"]  == "quantum"
            quantum_ip = endpoint["internalURL"]
          end
        end
      rescue
      end
    end
  
    #### Uncomment this section for testing on a clean slate ####
    #@to_delete = DeployedContainer.all
    #@to_delete.each do |container|
    #  destroy_deployed(container,token,nova_ip,quantum_ip)
    #end
    #############################################################

    # Deploy this container, and by implication all nested containers
    @deployed_container = deployHelper(@deployed_container,params[:id],params[:tenant_id],false,[],nil,token,nova_ip,quantum_ip)  

    # Cheap hack for demo purposes
    sleep(5)

    if @deployed_container.save
      # deploy.json.jbuilder will be used to provide a response
    else
      respond_to do |format|
        format.html { render :json => @deployed_container.errors, :status => :unprocessable_entity }
        format.json { render :json => @deployed_container.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Helper function to enable a recursive deployment sequence.
  # Deploys the given container onto the given network and calls itself
  # for all containers belonging to that conatiner, and so on. 
  # Returns data on the deployment status of the first given container on completion.
  def deployHelper(to_deploy,id,tenant,embedded,connected_endpoints,parent,token,nova_ip,quantum_ip)
    container = Container.find(id)
    deployed = to_deploy
    deployed.container_id = id
    deployed.tenant_id = tenant

    novaIP = URI.parse(nova_ip)
    nova =  Ropenstack::Nova.new(novaIP, token)

    quantumIP = URI.parse(quantum_ip)
    quantum = Ropenstack::Quantum.new(quantumIP, token)

    # All OpenStack communication is handled inside a begin-end block
    # If any errors are thrown all deployment actions up to that point will be rolled back
    # by calling the 'destroy_deployed' function
    # Therefore making container deployment an atomic action
    begin
      # All networks must be deployed first to allow routers and VMs to be created with active
      # connections
      container.networks.each do |network|
        # If the CIDR of the default subnet of a network has been defined as 'random'
        if network.cidr == "random"
          # then give it a random CIDR in the range 0.0.0.0/24 to 255.255.255.0/24
          network_cidr = "" + rand(256).to_s + "." + rand(256).to_s + "." + rand(256).to_s + "." + "0/24"
        else
          # otherwise, use the pre-defind CIDR
          network_cidr = network.cidr
        end
        n = deployed.deployed_networks.build()

        # Send the network creation request to OpenStack
        logger.info "ABOUT TO DEPLOY NETWORK"
        deployed_network = quantum.create_network(network.name,tenant)
        logger.info "NETWORK DEPLOYED:"
        logger.info deployed_network
 
        # Save relevant data in the Donabe database
        n.openstack_id = deployed_network["network"]["id"]
        n.cidr = network_cidr
        n.temp_id = network.temp_id
        n.endpoint = network.endpoint

        # Send the subnet creation request to OpenStack for this networks defualt subnet
        logger.info "ABOUT TO DEPLOY SUBNET"
        default_subnet =  quantum.create_subnet(n.openstack_id,n.cidr)
        logger.info "SUBNET DEPLOYED:"
        logger.info default_subnet

        # Save relevant data in the Donabe database
        n.default_subnet = default_subnet["subnet"]["id"]

        n.save
      end

      # After all networks have been successfuly deployed, deploy all routers
      container.routers.each do |router|
        r = deployed.deployed_routers.build()
        
        # Send the router creation request to OpenStack
        logger.info "ABOUT TO DEPLOY ROUTER"
        deployed_router = quantum.create_router(router.name)
        logger.info "ROUTER DEPLOYED:"
        logger.info deployed_router

        # Save relevant data in the Donabe database
        r.openstack_id = deployed_router["router"]["id"]
        r.temp_id = router.temp_id
        r.endpoint = router.endpoint
        r.save

        # We next need to create router interfaces to the default subnet of all networks
        # to which this router is connected
        router.connected_networks.each do |network|
          deployed.deployed_networks.each do |deployed_network|
            if network.temp_id == deployed_network.temp_id
              # Send the router interface creation request to OpenStack
              quantum.add_router_interface(r.openstack_id,deployed_network.default_subnet)

              # Save relevant data in the Donabe database
              connected_network = r.deployed_connected_networks.build()
              connected_network.openstack_id = deployed_network.openstack_id
              connected_network.save
            end
          end
        end
      end
   
      # After all routers have been successfully deployed, deploy all VMs
      container.vms.each do |vm|
        v = deployed.deployed_vms.build()
   
        # These arrays will keep track of important data regarding the virtual ports we
        # create for each vm. WE create the ports before the VMs to make good use
        # of OpenStacks ability to create a VM with a list of pre-defined ports
        ports = Array.new()
        port_list = Array.new()

        # We need one port in the defualt subnet of every network to which the VM is connected
        vm.connected_networks.each do |network|
          deployed.deployed_networks.each do |deployed_network|
            if network.temp_id == deployed_network.temp_id
              # Send the port creation request to OpenStack
              logger.info "ABOUT TO DEPLOY PORT"
              port = quantum.create_port(deployed_network.openstack_id,deployed_network.default_subnet,nil,"compute:nova")
              logger.info "PORT DEPLOYED:"
              logger.info port

              # Save relevant data in our ports array, and the Donabe database
              ports << port["port"]["id"]
              data = {'uuid'=>deployed_network.openstack_id, 'port'=>port["port"]["id"]}
              port_list << data
              connected_network = v.deployed_connected_networks.build()
              connected_network.openstack_id = deployed_network.openstack_id
              connected_network.save
            end
          end
        end

        # Send the VM creation request to OpenStack
        logger.info "ABOUT TO DEPLOY VM"
        deployed_vm = nova.create_server(vm.name,vm.image_id,vm.flavor,port_list,nil)
        logger.info "VM DEPLOYED:"
        logger.info deployed_vm

        # Save relevant data in the Donabe database
        v.openstack_id = deployed_vm["server"]["id"]
        v.temp_id = vm.temp_id
        v.image_id = vm.image_id
        v.image_name = vm.image_name
        v.name = vm.name
        v.flavor = vm.flavor
        v.endpoint = vm.endpoint
        ports.each do |port_id|
          port = v.ports.build()
          port.port_id = port_id
          port.save
        end
        v.save
      end

      # Now we have to do some extra work if the container we're deploying is itself being
      # deployed as part of another container. This involves networking all nodes that are  
      # connected together across both containers
      if parent != nil
        # We look for these connections by iterating over the list of 'connected_endpoints'
        # defined in the parent container
        connected_endpoints.each do |endpoint|
          # For every node which as defined as being connected to a corresponding node in the
          # parent conatainer, be it a router, network, or vm, we create the relevant connection
          # in OpenStack and save all relevant data in the Donabe databse, just as above
          deployed.deployed_routers.each do |router|
            if endpoint.endpoint_id == router.temp_id
              parent.deployed_networks.each do |network|
                if endpoint.connected_id == network.temp_id
                  quantum.add_router_interface(router.openstack_id,network.default_subnet)
                  connected_network = router.deployed_connected_networks.build()
                  connected_network.openstack_id = network.openstack_id
                  connected_network.save
                end
              end
            end
          end
          deployed.deployed_networks.each do |network|
            if endpoint.endpoint_id == network.temp_id
              parent.deployed_routers.each do |router|
                if endpoint.connected_id == router.temp_id
                  quantum.add_router_interface(router.openstack_id,network.default_subnet)
                  connected_network = router.deployed_connected_networks.build()
                  connected_network.openstack_id = network.openstack_id
                  connected_network.save
                end
              end
              parent.deployed_vms.each do |vm|
                if endpoint.connected_id == vm.temp_id
                  connected_network = vm.deployed_connected_networks.build()
                  connected_network.openstack_id = network.openstack_id
                  connected_network.save
                  port_id = quantum.create_port(network.openstack_id,network.default_subnet,vm.openstack_id,"compute:nova")
                  port_id = port_id["port"]["id"]
                  port = vm.ports.build()
                  port.port_id = port_id
                  port.save
                end
              end
            end
          end
          deployed.deployed_vms.each do |vm|
            if endpoint.endpoint_id == vm.temp_id
              parent.deployed_networks.each do |network|
                if endpoint.connected_id == network.temp_id
                  connected_network = vm.deployed_connected_networks.build()
                  connected_network.openstack_id = network.openstack_id
                  connected_network.save
                  port_id = quantum.create_port(network.openstack_id,network.default_subnet,vm.openstack_id,"compute:nova")
                  port_id = port_id["port"]["id"]
                  port = vm.ports.build()
                  port.port_id = port_id
                  port.save
                end
              end
            end
          end
        end
      end

      # At this point all nodes belonging to this container have been deployed, and all
      # connections to the parent container (if it exists) have been established. Now we
      # must call this same function again for all containers which are embedded in this one
      container.embedded_containers.each do |embedded_container|
        connected_endpoints = embedded_container.connected_endpoints.all
        child_container = deployHelper(deployed.deployed_containers.build(),embedded_container.embedded_container_id,tenant,true,connected_endpoints,deployed.clone,token,nova_ip,quantum_ip)
        if child_container == nil
          raise 'uh oh'
        end
      end

      # Perform a simple check to determine if the container currently being deployed is
      # at the top level of a hierarchy tree, or if it is itself embedded in another container.
      if not embedded
        # If it is the top level container, return itself to the deploy methof for passing to
        # the caller
        return deployed
      else
        # If it is embedded, save itself and return to the deploy method of the parent
        # container to confirm successful deployment
        deployed.save
        return deployed
      end

    rescue
      # If at any point in the deployment process an error is thrown, we want to undo all actions
      destroy_deployed(deployed,token,nova_ip,quantum_ip)
      if not embedded
        deployed = DeployedContainer.new()
        deployed.container_id = nil
        return deployed
      else
        return nil
      end
    end
  end

  # Rollback all OpenStack Actions caused by a container deployment
  def destroy_deployed(deployed,token,nova_ip,quantum_ip)
    novaIP = URI.parse(nova_ip)
    nova =  Ropenstack::Nova.new(novaIP, token)

    quantumIP = URI.parse(quantum_ip)
    quantum = Ropenstack::Quantum.new(quantumIP, token)
    # Delete VMs and Ports
    deployed.deployed_vms.each do |vm|
      begin
        nova.delete_server(vm.openstack_id)
        vm.ports.each do |port|
          quantum.delete_port(port.port_id)
        end
      rescue
      end
      vm.deployed_connected_networks.each do |network|
        network.destroy
      end
      vm.destroy
    end
    # Delete VMs and Ports for nested containers
    deployed.deployed_containers.each do |container|
      container.deployed_vms.each do |vm|
        begin
          nova.delete_server(vm.openstack_id)
          vm.ports.each do |port|
            quantum.delete_port(port.port_id)
          end
        rescue
        end
        vm.deployed_connected_networks.each do |network|
          network.destroy
        end
        vm.destroy
      end
    end
    # Delete Router interfaces
    deployed.deployed_routers.each do |router|
      router.deployed_connected_networks.each do |network| 
        begin
        quantum.delete_router_interface(router.openstack_id,network.default_subnet,'network')
        rescue
        end
        network.destroy
      end
    end
    # Delete Router interfaces for nested containers
    deployed.deployed_containers.each do |container|
      container.deployed_routers.each do |router|
        router.deployed_connected_networks.each do |network| 
          begin
          quantum.delete_router_interface(router.openstack_id,network.default_subnet,'network')
          rescue
          end
          network.destroy
        end
      end
    end
    # Delete Subnets
    deployed.deployed_networks.each do |network|
      begin
      quantum.delete_subnet(network.default_subnet)
      quantum.delete_network(network.openstack_id)
      rescue
      end
      network.destroy
    end
    # Delete Subnets for nested containers
    deployed.deployed_containers.each do |container|
      container.deployed_networks.each do |network|
        begin
        quantum.delete_subnet(network.default_subnet)
        quantum.delete_network(network.openstack_id)
        rescue
        end
        network.destroy
      end
    end
    # Delete Routers
    deployed.deployed_routers.each do |router|
      begin
      quantum.delete_router(router.openstack_id)
      rescue
      end
      router.destroy
    end
    # Delete Routers for nested containers
    deployed.deployed_containers.each do |container|
      container.deployed_routers.each do |router|
        begin
        quantum.delete_router(router.openstack_id)
        rescue
        end
        router.destroy
      end
    end
    deployed.deployed_containers.each do |container|
      destroy_deployed(container,token)
    end
    deployed.destroy
  end

  # :tenant_id/deployed_containers/destroy_deployed/:id.json
  # Simple passthrough function to allow the destruction of deployed containers via REST
  def destroy_deployed_REST
    @deployed = DeployedContainer.find(params[:id])

    if request.headers["X-Auth-Token"] != ""
      token = request.headers["X-Auth-Token"]
      services = Donabe::KEYSTONE.get_endpoints(token)
      services["endpoints"].each do |endpoint|
        if endpoint["name"] == "nova"
          nova_ip = endpoint["internalURL"]
        elsif endpoint["name"]  == "quantum"
          quantum_ip = endpoint["internalURL"]
        end
      end
    else
      token = cookies[:current_token]
      nova_ip = Storage.find(cookies[:nova_ip]).data
      quantum_ip = Storage.find(cookies[:quantum_ip]).data
    end
    
    destroy_deployed(@deployed,token)

    respond_to do |format|
      format.html { redirect_to deployed_containers_path }
      format.json { redirect_to deployed_containers_path }
    end
  end

  # DELETE tenant_id/containers/:id.json
  def destroy
    @container = Container.find(params[:id])
    @container.destroy

    respond_to do |format|
      format.html { redirect_to containers_path }
      format.json { redirect_to containers_path }
    end
  end
end
