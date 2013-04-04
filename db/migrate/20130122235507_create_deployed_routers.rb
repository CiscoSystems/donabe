class CreateDeployedRouters < ActiveRecord::Migration
  def change
    create_table :deployed_routers do |t|
      t.string :openstack_id
      t.string :temp_id
      t.boolean :endpoint
      t.references :deployed_container

      t.timestamps
    end
    add_index :deployed_routers, :deployed_container_id
  end
end
