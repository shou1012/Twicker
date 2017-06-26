class Favorite < ApplicationRecord
  belongs_to :user
  validates :user_id, uniqueness: { scope: [:timeline_source, :timeline_id] }
end
