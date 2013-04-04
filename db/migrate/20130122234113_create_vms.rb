class CreateVms < ActiveRecord::Migration
  def change
    create_table :vms do |t|
      t.string :image_name
      t.string :image_id
      t.string :name
      t.string :temp_id
      t.string :flavor
      t.boolean :endpoint
      t.references :container
      t.references :network_design

      t.timestamps
    end
    add_index :vms, :container_id
    add_index :vms, :network_design_id
  end
end
