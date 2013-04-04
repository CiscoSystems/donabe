class CreateNetworks < ActiveRecord::Migration
  def change
    create_table :networks do |t|
      t.string :name
      t.string :cidr
      t.string :temp_id
      t.boolean :endpoint
      t.references :container

      t.timestamps
    end
    add_index :networks, :container_id
  end
end
