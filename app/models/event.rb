class Event < ActiveRecord::Base
  validates :name, :presence => true #Makes sure all useres have a name
  validates :start, :presence => true #Makes sure all useres have a unique name
  validates :end, :presence => true #Makes sure all useres have a unique name    
end
