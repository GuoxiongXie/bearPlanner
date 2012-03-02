class Event < ActiveRecord::Base
  validates :name, :presence => true #Makes sure all useres have a name
  validates :start, :presence => true #Makes sure all useres have a unique name
  validates :end, :presence => true #Makes sure all useres have a unique name
  validates :calendar_id, :presence => true #Makes sure all useres have a unique name
  
  has_many :users  #DEBUG: calendars need s??
  has_many :invites    
end
