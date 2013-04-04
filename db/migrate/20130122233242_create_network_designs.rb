class CreateNetworkDesigns < ActiveRecord::Migration
  def change
    create_table :network_designs do |t|
      t.string :name
      t.boolean :read
      t.string :body

      t.timestamps
    end
  end
end
