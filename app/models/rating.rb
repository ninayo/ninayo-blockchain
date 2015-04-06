class Rating < ActiveRecord::Base
	after_commit :update_user_ratings
	belongs_to :ad
	belongs_to :user
	belongs_to :rater, :class_name => "User", :foreign_key => "rater_id"

	enum role: [:buyer, :seller]

	validates :ad_id, :user_id, :rater_id, :score, :role, presence: true
	# validates :score, numericality: { :only_integer => true, :greater_than => 0, :key => "value", :less_than_or_equal_to => 5 }

	private

	def update_user_ratings
		#self.user.update(:seller_rating => self.user.seller_score, :buyer_rating => self.user.buyer_score)
		seller_rating = self.user.ratings.seller.average(:score) || 0
		buyer_rating =  self.user.ratings.buyer.average(:score) || 0
		self.user.update(:seller_rating => seller_rating, :buyer_rating => buyer_rating)
	end
end