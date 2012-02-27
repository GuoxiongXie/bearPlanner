class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name #with a column called "name" of type "string"
      t.string :start #and a column called "description" of type "string"
      t.string :end
      t.timestamps
    end
  end
end
