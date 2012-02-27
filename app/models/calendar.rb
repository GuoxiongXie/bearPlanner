class Calendar < ActiveRecord::Base
  validates :name, :presence => true #Makes sure all calendars have a name. DEBUG: unique???    
end
