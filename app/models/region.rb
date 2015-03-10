class Region < ActiveRecord::Base
	has_many :ads
	has_many :users
end
