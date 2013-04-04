require 'net/http'
require 'json'
require 'uri'

##QuantumV2 related rest API calls
##http://wiki.openstack.org/QuantumV2APIIntro
class QuantumRestController < ApplicationController
	def getNetworks
		json_respond(quantum().networks())
	end

	def getSubnets
		json_respond(quantum().subnets())
  	end

	def getPorts
		json_respond(quantum().ports())
	end

	def getRouters
		json_respond(quantum().routers())
	end

	def createNetwork
		json_respond(quantum().create_network(params[:name], Storage.find(cookies[:current_tenant]).data))
	end

	def createSubnet
		json_respond(quantum().create_subnet(params[:network_id], params[:cidr]))
	end

	def createPort
		json_respond(quantum().create_port(params[:network_id], params[:device_id]))
	end

	def createRouter
		json_respond(quantum().create_router(params[:name]))
	end

	def addInterfaceRouter
		json_respond(quantum().add_router_interface(params[:routerID], params[:subnetID]))
	end

 	def addRouterGateway
		json_respond(quantum().add_router_gateway(params[:router]["id"], params[:router][:external_gateway_info]))
        end

	def deletePort
		json_respond(quantum().delete_port(params[:portID]))
	end

	def terminateSubnet
	    	json_respond(quantum().delete_subnet(params[:subnetID]))
	end

	def deleteNetwork
		json_respond(quantum().delete_network(params[:networkID]))
	end

	def deleteRouterGateway
		json_respond(quantum().delete_router_gateway(params[:routerID]))
	end

	def terminateRouter
		##Little more complex than other controllers, deletes the routers interface first, to avoid failure.
		quan = quantum()
		quan.ports()["ports"].each do |port| 
			if port["device_id"] == params[:routerID]
				quan.delete_router_interface(params[:routerID], port["id"], 'port')
		  	end
                end
		json_respond(quan.delete_router(params[:routerID]))
	end

	def terminateRouterInterface
		json_respond(quantum().delete_router_interface(params[:routerID], params[:subnetID], 'subnet'))
	end
end
