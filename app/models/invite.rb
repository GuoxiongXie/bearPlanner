class Invite < ActiveRecord::Base
  validates_uniqueness_of :users_id, :scope => :event_id#Need to verify the correctness of the syntax
  validates :users_id, :presence => true #Makes sure all useres have a name
end
