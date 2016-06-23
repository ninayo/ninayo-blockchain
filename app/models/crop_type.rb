class CropType < ActiveRecord::Base
	has_many :ads

  def is_other
  end
  
end
