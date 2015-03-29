class CreateAd
	include ActiveModel::Validations 

	# Kolla http://api.rubyonrails.org/classes/ActiveModel/Validations.html

	# attr_accessor :first_name, :last_name

	# def initialize
	# 	@ad = Ad.new
	# end

	# validates_each :first_name, :last_name do |record, attr, value|
	# 	record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
	# end

end