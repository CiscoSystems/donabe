class CreatePorts < ActiveRecord::Migration
  def change
    create_table :ports do |t|
      t.string :port_id
      t.references :deployed_vm

      t.timestamps
    end
    add_index :ports, :deployed_vm_id
  end
end
