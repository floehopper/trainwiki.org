class Event < ActiveRecord::Base

  belongs_to :journey
  belongs_to :station

  validates_presence_of :journey
  validates_presence_of :station
  validates_presence_of :timetabled_at

end