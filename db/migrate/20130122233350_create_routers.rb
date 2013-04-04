class CreateRouters < ActiveRecord::Migration
  def change
    create_table :routers do |t|
      t.string :name
      t.string :temp_id
      t.boolean :endpoint
      t.references :container
      t.references :network_design

      t.timestamps
    end
    add_index :routers, :container_id
  end
end
