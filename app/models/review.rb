class Review < ActiveRecord::Base
  MAX_RATING = 5.0
  belongs_to :place
  belongs_to :user

  validates :body, :note, presence: true
  validates :note, numericality: { only_integer: true }
  #TODO: add validation on the range of note

  after_save :compute_place_avg
  after_destroy :compute_place_avg

  private

  def compute_place_avg
    self.place.compute_avg!
  end
end
