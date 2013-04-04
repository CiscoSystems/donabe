class CreateEmbeddedContainers < ActiveRecord::Migration
  def change
    create_table :embedded_containers do |t|
      t.string :embedded_container_id
      t.boolean :endpoint
      t.references :container
      t.references :network_design

      t.timestamps
    end
    add_index :embedded_containers, :container_id
    add_index :embedded_containers, :network_design_id
  end
end
