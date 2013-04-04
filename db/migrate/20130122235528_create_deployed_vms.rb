class CreateDeployedVms < ActiveRecord::Migration
  def change
    create_table :deployed_vms do |t|
      t.string :openstack_id
      t.string :image_name
      t.string :image_id
      t.string :name
      t.string :temp_id
      t.string :flavor
      t.boolean :endpoint
      t.references :deployed_container

      t.timestamps
    end
    add_index :deployed_vms, :deployed_container_id
  end
end
