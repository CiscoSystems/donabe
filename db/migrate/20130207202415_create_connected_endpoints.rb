class CreateConnectedEndpoints < ActiveRecord::Migration
  def change
    create_table :connected_endpoints do |t|
      t.string :endpoint_id
      t.string :connected_id
      t.references :embedded_container

      t.timestamps
    end
    add_index :connected_endpoints, :embedded_container_id
  end
end
