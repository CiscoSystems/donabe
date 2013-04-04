class CreateEndpoints < ActiveRecord::Migration
  def change
    create_table :endpoints do |t|
      t.string :name
      t.string :type
      t.string :endpoint_id
      t.references :container

      t.timestamps
    end
    add_index :endpoints, :container_id
  end
end
