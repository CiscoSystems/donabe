class CreateConnectedNetworks < ActiveRecord::Migration
  def change
    create_table :connected_networks do |t|
      t.string :temp_id
      t.references :vm
      t.references :router

      t.timestamps
    end
    add_index :connected_networks, :vm_id
    add_index :connected_networks, :router_id
  end
end
