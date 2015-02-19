class Ad < ActiveRecord::Base
	belongs_to :user
	belongs_to :crop_type

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
end
