class CreateFlavors < ActiveRecord::Migration
  def change
    create_table :flavors do |t|
      t.string :name
      t.integer :uuid

      t.timestamps
    end
  end
end
