class Ad < ActiveRecord::Base
	include Filterable

	belongs_to :user, autosave: true
	accepts_nested_attributes_for :user


	belongs_to :buyer, :class_name => "User", :foreign_key => "buyer_id"
	accepts_nested_attributes_for :buyer

	belongs_to :crop_type
	belongs_to :region
	has_many :ad_logs
	has_many :speculators, through: :ad_logs, source: :user
	has_many :favorite_ads
	has_many :favorited_by, through: :favorite_ads, source: :user

	has_many :ratings

	before_save	:set_published_at
	before_save	:set_archived_at

	after_initialize :set_default_status, :if => :new_record?

	validates :lat, :lng, presence: { message: "The location of your crop is required" }
	validates :region_id, presence: { message: "The regions is required" }

	validates :crop_type, :price, :volume, :volume_unit, :village, :user, presence: true
	validates :crop_type_id, numericality: { greater_than: 0 }
	validates :price, :volume, numericality: true
	validates :final_price, presence: true, if: "archived?"
	validates :other_crop_type, presence: true, if: "crop_type.id == 10"

	validates :buyer_price, presence: true, on: :save_buyer_info

	enum volume_unit: [:bucket, :sack]
	enum status: [:draft, :published, :archived, :pending_review, :rejected, :spam]

	scope :crop_type_id, -> (crop_type_id) { where crop_type_id: crop_type_id }
	scope :volume_min, -> (volume_min) { where("volume > ?", volume_min) }
	scope :volume_max, -> (volume_max) { where("volume < ?", volume_max) }
	#scope :price_min, -> (price_min) { where("price > ?", price_min) }
	scope :price_min, -> (price_min) { where("price > " + price_min) }
	scope :price_max, -> (price_max) { where("price < " + price_max) }
	scope :region_id, -> (region_id) { where region_id: region_id }


	def title
		if self.crop_type.id == 10
			crop_type = self.other_crop_type
		else
			crop_type = self.crop_type.name
		end

		if self.volume && self.crop_type
			"#{self.volume} #{self.volume_unit.pluralize(self.volume)} of #{crop_type}"
		end
	end

	def crop_type_name
		if self.crop_type_id == 10
			self.other_crop_type
		else
			self.crop_type.name
		end
	end


	def favorite?(user = nil)
		if user
			self.favorited_by.where(:id => user.id).exists?
		else
			false
		end
	end

protected

	def set_default_status
		self.status ||= :draft
	end

	def set_published_at
		if self.published? && !self.published_at
			self.published_at = Time.new
		end
	end

	def set_archived_at
		if self.archived? && !self.archived_at
			self.archived_at = Time.new
		end
	end
end
