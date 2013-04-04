class CreateConnectedVms < ActiveRecord::Migration
  def change
    create_table :connected_vms do |t|
      t.string :temp_id
      t.references :embedded_container

      t.timestamps
    end
    add_index :connected_vms, :embedded_container_id
  end
end
