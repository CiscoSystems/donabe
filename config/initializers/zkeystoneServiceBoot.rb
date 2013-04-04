##Registers Service with OpenStack keystone.
##Starts with a z becuase the initialisers are executed alphabetically, derp.
require 'ropenstack/openstackservice'
require 'ropenstack'
require 'net/http'
require 'json'
require 'uri'

ip = APP_CONFIG["keystone"]["ip"]
port = APP_CONFIG["keystone"]["admin_port"]

puts "ADDING TO KEYSTONE SERVICE CATALOG"

Donabe::KEYSTONE = Ropenstack::Keystone.new(ip, port)
Donabe::KEYSTONE.authenticate(APP_CONFIG["keystone"]["username"], APP_CONFIG["keystone"]["password"])
Donabe::KEYSTONE.scope_token(APP_CONFIG["keystone"]["tenant"])

services = Donabe::KEYSTONE.get_services()

donabePresent = false
donabeID = ""
for service in services["OS-KSADM:services"]
	if service["name"] == "donabe"
		donabePresent = true
		donabeID = service['id']
	end
end

if !donabePresent
	response = Donabe::KEYSTONE.add_to_services("donabe","container","Donabe Container Service")
	services = Donabe::KEYSTONE.get_services()
	for service in services["OS-KSADM:services"]
		if service["name"] == "donabe"
			donabeID = service['id']
		end
	end
end

puts "ADDING KEYSTONE ENDPOINT"

donabeRegion = APP_CONFIG["region"]
donabePublicUrl = APP_CONFIG["publicurl"]
donabeAdminUrl = APP_CONFIG["adminurl"]
donabeInternalUrl = APP_CONFIG["internalurl"]

endpoints = Donabe::KEYSTONE.get_endpoints()

endpointAlreadyPresent = false
for endpoint in endpoints["endpoints"]
	if endpoint["service_id"] == donabeID and
	   endpoint["publicurl"] == donabePublicUrl and
	   endpoint["adminurl"] == donabeAdminUrl and
	   endpoint["internalurl"] == donabeInternalUrl
	
		endpointAlreadyPresent = true
	end
end

if !endpointAlreadyPresent
	Donabe::KEYSTONE.add_endpoint(donabeRegion, donabeID, donabePublicUrl, donabeAdminUrl, donabeInternalUrl)
end

puts "KEYSTONE CONFIG DONE"
puts donabeID

