class Rating < ActiveRecord::Base
	belongs_to :ad
	belongs_to :user
	belongs_to :rater, :class_name => "User", :foreign_key => "rater_id"

	enum role: [:buyer, :seller]

	validates :ad_id, :user_id, :rater_id, :score, :role, presence: true
	# validates :score, numericality: { :only_integer => true, :greater_than => 0, :key => "value", :less_than_or_equal_to => 5 }
end
