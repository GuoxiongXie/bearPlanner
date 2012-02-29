class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name #with a column called "name" of type "string"
      t.datetime :start #DateTime???
      t.datetime :end
      t.timestamps
    end
  end
end
