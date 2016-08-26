class Region < ActiveRecord::Base
	has_many :ads
	has_many :users
  has_many :districts
  has_many :wards, through: :districts
end
