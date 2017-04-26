class Price < ActiveRecord::Base

  before_validation :adjust_price

  belongs_to :crop_type
  belongs_to :region

  validates :region_id, :crop_type_id, :price, presence: true
  validates :price, numericality: { less_than_or_equal_to: 999_999_999 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def adjust_price
    self.price = self.price.sub!(',', '.') if self.price && self.price.is_a?(String) && self.price.count(',') > 0
  end

  def related_ads
  	Ad.where(:ad_type => 0,
	          :crop_type_id => self.crop_type_id,
	          :region_id => self.region_id).order("published_at").last(3).reverse
  end
end
