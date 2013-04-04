class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string :name
      t.string :body
      t.boolean :read
      t.string :tenant_id

      t.timestamps
    end
  end
end
