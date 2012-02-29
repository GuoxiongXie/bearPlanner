class Invitees < ActiveRecord::Base
  validates_uniqueness_of :uid, :scope => :eid#Need to verify the correctness of the syntax
end
