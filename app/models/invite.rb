class Invite < ActiveRecord::Base
  validates_uniqueness_of :users_id, :scope => :event_id#Need to verify the correctness of the syntax
end
