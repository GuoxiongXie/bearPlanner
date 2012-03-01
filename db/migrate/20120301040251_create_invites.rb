class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      #t.integer :eid #event ID
      #t.integer :uid #user ID
      t.boolean :accept
      t.string :msg

      t.references :event #verify adding a "s" after "event"
      t.references :users
      
      t.timestamps
      
    end
  end
end
