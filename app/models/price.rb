class Price < ActiveRecord::Base

  before_validation :adjust_price

  belongs_to :crop_type
  belongs_to :region

  validates :region_id, :crop_type, :price, presence: true

  def adjust_price
    self.price = self.price.sub!(',', '.') if self.price && self.price.is_a?(String) && self.price.count(',') > 0
  end

end
