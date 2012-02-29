class Event < ActiveRecord::Base
  validates :name, :presence => true #Makes sure all useres have a name
  validates :start, :presence => true #Makes sure all useres have a unique name
  validates :end, :presence => true #Makes sure all useres have a unique name
  
<<<<<<< HEAD
  #belongs_to :calendar #DEBUG: calendars??? need it or not??
=======
  #belongs_to :calendar #DEBUG: calendars???
>>>>>>> 7ca358d0a2a5f3a74d2dc5e324a184767c06e956
  has_many :users  #DEBUG: calendars need s??    
end
