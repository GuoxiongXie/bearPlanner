class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name #with a column called "name" of type "string"
      t.datetime :start #DateTime???
      t.datetime :end
      t.integer :inviteID
      t.timestamps
      
      t.references :calendar
      t.references :users  #the user_id will used as ownerID
      #belongs_to :calendars  #DEBUG:need it or not
    end
  end
end
