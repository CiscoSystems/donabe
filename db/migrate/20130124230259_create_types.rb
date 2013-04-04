class CreateTypes < ActiveRecord::Migration
  def change
    create_table :types do |t|
      t.string :name
      t.string :image
      t.string :flavor
      t.references :container
      t.references :network_design

      t.timestamps
    end
    add_index :types, :container_id
    add_index :types, :network_design_id
  end
end
