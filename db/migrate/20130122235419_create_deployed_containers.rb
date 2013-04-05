class CreateDeployedContainers < ActiveRecord::Migration
  def change
    create_table :deployed_containers do |t|
      t.integer :container_id
      t.string :tenant_id
      t.string :name
      t.references :deployed_container

      t.timestamps
    end
    add_index :deployed_containers, :deployed_container_id
  end
end
