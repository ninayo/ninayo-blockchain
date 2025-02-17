class Ad < ActiveRecord::Base
  include Filterable

  before_validation :adjust_price

  before_save :set_published_at
  before_save :set_archived_at

  after_initialize :set_default_status, if: :new_record?

  # Associations
  belongs_to :user, autosave: true
  accepts_nested_attributes_for :user

  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  accepts_nested_attributes_for :buyer

  belongs_to :crop_type
  belongs_to :region
  belongs_to :district
  belongs_to :ward
  has_many :ad_logs
  has_many :speculators, through: :ad_logs, source: :user
  has_many :favorite_ads
  has_many :favorited_by, through: :favorite_ads, source: :user

  has_many :ratings

  has_many :comments

  has_many :calls, class_name: 'CallLog', foreign_key: 'ad_id'
  has_many :texts, class_name: 'TextLog', foreign_key: 'ad_id'

  validates :ad_type, presence: true
  validates :crop_type, :price, :volume, :volume_unit, :user, presence: true
  validates :crop_type_id, numericality: { greater_than: 0 }
  validates :price, :volume, numericality: true
  validates :final_price, presence: true, if: 'archived?'
  validates :other_crop_type, presence: true, if: 'crop_type.id == 10'

  validates :buyer_price, presence: true, on: :save_buyer_info

  validates :region_id, :district_id, presence: true, on: :create

  validates :other_crop_type, exclusion: { in: ['marijuana', 'malijuana', 'bangi'] }, if: 'crop_type.id == 10'

  # Enums
  enum volume_unit: [:bucket, :sack, :kg, :gunia, :trees, :mkungu, :fungu, :tenga, :moja, :debe, :chane, :sado, :tonne, :litre]
  enum status: [:draft, :published, :archived, :pending_review, :rejected, :spam, :deleted]
  enum ad_type: [:sell, :buy]

  # Scopes
  scope :crop_type_id, -> (crop_type_id) { where crop_type_id: crop_type_id }
  scope :volume_min, -> (volume_min) { where("volume > ?", volume_min) }
  scope :volume_max, -> (volume_max) { where("volume < ?", volume_max) }
  scope :price_min, -> (price_min) { where("price > ?", price_min) }
  scope :price_max, -> (price_max) { where("price < ?", price_max) }
  scope :region_id, -> (region_id) { where region_id: region_id }

  scope :bought, -> { where.not(buyer_price: nil) }

  def title
    if crop_type.id == 10
      crop_type = other_crop_type
    elsif I18n.locale == :sw
      crop_type = self.crop_type.name_sw
    else
      crop_type = self.crop_type.name
    end

    if self.volume && self.crop_type
      volume = I18n.t("volume_units.#{self.volume_unit}", count: self.volume);
      "#{volume} #{I18n.t 'common.of2'} #{crop_type}"
    end
  end

  def self.bought_ads(user)
    self.where(user: user).where.not(buyer_price: nil)
  end

  def crop_type_name
    crop_type_id == 10 ? other_crop_type : crop_type.name
  end

  def favorite?(user = nil)
    user ? favorited_by.where(id: user.id).exists? : false
  end

  def related_ads
    if ad_type == 'sell'
      Ad.where("created_at >= ? OR updated_at >= ?", 2.weeks.ago, 2.weeks.ago)
        .where(ad_type: 1,
               crop_type_id: crop_type_id,
               volume_unit: Ad.volume_units[volume_unit],
               region_id: region_id).order('published_at')
        .last(3).reverse
    else
      Ad.where("created_at >= ? OR updated_at >= ?", 2.weeks.ago, 2.weeks.ago)
        .where(ad_type: 0,
               crop_type_id: crop_type_id,
               volume_unit: Ad.volume_units[volume_unit],
               region_id: region_id).order('published_at')
        .last(3).reverse
    end
  end

  def self.ads_per_day
    select("date(published_at) as ad_date, count(*) as ad_count").group("date(published_at)").order("date(published_at)")
  end

  def self.transactions_per_day
    select("date(archived_at) as ad_date, count(*) as ad_count").where("status = 2").group("date(archived_at)").order("date(archived_at)")
  end

  def self.crop_type_stats
    select("crop_type_id, count(*) as ad_count")
      .group("crop_type_id")
      .order("crop_type_id")
  end

  def self.contact_ratio(num)
    contacts = Ad.last(num).select { |a| a.contact_count >= 1 }.count
    "Last #{num} ads - #{contacts} non-internal contacts - " \
    "Total ratio: #{(contacts.to_f / num.to_f)}"
  end

  def contact_count
    calls.reject { |c| c.caller.phone_number == ('0758245054' || c.receiver.phone_number) }.count + texts.reject { |t| t.sender.phone_number == ('0758245054' || t.receiver.phone_number) }.count
  end

  # don't return user object when rendering as json
  # otherwise we can get phone numbers scraped
  def as_json(options = {})
    super(options.merge({ except: [:user] }))
  end

  protected

  def adjust_price
    self.price = self.price.sub!(",", ".") if self.price && self.price.kind_of?(String) && self.price.count(",") > 0
  end

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