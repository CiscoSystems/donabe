class CreateDeployedNetworks < ActiveRecord::Migration
  def change
    create_table :deployed_networks do |t|
      t.string :openstack_id
      t.string :cidr
      t.string :default_subnet
      t.string :temp_id
      t.boolean :endpoint
      t.references :deployed_container

      t.timestamps
    end
    add_index :deployed_networks, :deployed_container_id
  end
end
