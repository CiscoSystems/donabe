class CreateConnectedRouters < ActiveRecord::Migration
  def change
    create_table :connected_routers do |t|
      t.string :temp_id
      t.references :network
      t.references :embedded_container

      t.timestamps
    end
    add_index :connected_routers, :network_id
    add_index :connected_routers, :embedded_container_id
  end
end
