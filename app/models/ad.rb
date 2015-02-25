class Ad < ActiveRecord::Base
	include Filterable
	belongs_to :user
	belongs_to :crop_type

	before_save	:set_published_at
	after_initialize :set_default_status, :if => :new_record?

	validates :crop_type, :price, :volume, :volume_unit, :village, :region, :user, presence: true
	validates :crop_type_id, numericality: { greater_than: 0 }
	validates :price, :volume, numericality: true

	enum volume_unit: [:bucket, :sack]
	enum status: [:draft, :published, :archived]

	scope :crop_type_id, -> (crop_type_id) { where crop_type_id: crop_type_id }


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
