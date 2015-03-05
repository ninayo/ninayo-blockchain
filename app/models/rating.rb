class Rating < ActiveRecord::Base
	belongs_to :ad
	belongs_to :user

	enum role: [:buyer, :seller]

	validates :ad_id, :user_id, :rater_id, :score, :role, presence: true
end
