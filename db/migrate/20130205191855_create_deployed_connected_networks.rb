class CreateDeployedConnectedNetworks < ActiveRecord::Migration
  def change
    create_table :deployed_connected_networks do |t|
      t.string :openstack_id
      t.string :default_subnet
      t.references :deployed_vm
      t.references :deployed_router

      t.timestamps
    end
    add_index :deployed_connected_networks, :deployed_vm_id
    add_index :deployed_connected_networks, :deployed_router_id
  end
end
