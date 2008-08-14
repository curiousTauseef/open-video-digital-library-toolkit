class Descriptor < ActiveRecord::Base

  validates_presence_of :descriptor_type
  validates_presence_of :text

  belongs_to :descriptor_type

  # Don't do this ... don't want to load all the videos everytime we
  # talk about this descriptor ...
  
  has_and_belongs_to_many :videos

  def most_recent
    # bad idea ... see above ...
    # and don't know why the reload is necessary to get the
    # time stamps: if the recode for paging doesn't get rid of the
    # need for this code, track it down ...
    videos.each &:reload
    ( videos.sort { |a,b| a.created_at - b.created_at } )[0]
  end

end