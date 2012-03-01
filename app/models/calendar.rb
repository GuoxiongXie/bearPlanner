class Calendar < ActiveRecord::Base
  validates :name, :presence => true #Makes sure all calendars have a name. DEBUG: unique???  
  validates_uniqueness_of :users_id, :scope => :name #Need to verify the correctness of the syntax  
  has_many :events  #DEBUG: events need s??
end
