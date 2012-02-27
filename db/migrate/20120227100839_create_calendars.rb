class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.string :name #with a column called "name" of type "string"
      t.string :description #and a column called "description" of type "string" 
      t.timestamps
    end
  end
end
