require 'ropenstack'
require 'uri'

keystone = Ropenstack::Keystone.new('172.29.74.219', '5000')
keystone.authenticate('admin', 'nova')
keystone.scope_token('admin')

rest = Ropenstack::Rest.new()

address = URI.parse("http://localhost:3000/#{keystone.tenant_id()}/containers")
puts rest.get_request(address, keystone.token())
