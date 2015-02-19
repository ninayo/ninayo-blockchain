class Ad < ActiveRecord::Base
	belongs_to :user
	belongs_to :crop_type

	before_save	:set_published_at
	after_initialize :set_default_status, :if => :new_record?

	validates :crop_type, presence: true
	validates :price, presence: true
	validates :volume, presence: true
	validates :volume_unit, presence: true
	validates :village, presence: true
	validates :region, presence: true

	validates :user, presence: true

	enum volume_unit: [:bucket, :sack]
	enum status: [:draft, :published, :archived]


	def title
		if self.volume && self.crop_type
			"#{self.volume} #{self.volume_unit.pluralize(self.volume)} of #{self.crop_type.name}"
		end
	end

	def set_default_status
		self.status ||= :draft
	end

	def set_published_at
		if self.published? && !self.published_at
			self.published_at = Time.new
		end
	end
end
