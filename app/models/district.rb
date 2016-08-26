class District < ActiveRecord::Base
  has_many :wards
  belongs_to :region
end
