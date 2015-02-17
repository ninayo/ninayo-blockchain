# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



1.upto(10) do |i|
	crop_type = CropType.new
	crop_type.name = 'Crop Type ' + i.to_s
	crop_type.save!
end

crop_type = CropType.new
crop_type.name = 'Maize'
crop_type.save!

puts 'CREATED 11 CROP_TYPES'


user = User.new
user.email = 'gabriel@svennerberg.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.role = 'admin'
user.name = 'Gabriel Svennerberg'
user.language = 'en'
user.save!

1.upto(100) do |i|
	ad = Ad.new
	ad.description = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eaque, impedit ipsam laborum nostrum illum nihil, id qui maiores voluptates aperiam animi quisquam, deserunt cupiditate maxime commodi placeat enim, autem quas!"
	ad.price = 5000 * i
	ad.volume = i
	ad.volume_unit = 'sack'
	ad.user = user
	ad.crop_type = crop_type
	ad.village = 'Mbola'
	ad.region = 'Uyui'
	ad.save!
end
puts 'CREATED 100 ADS by ' << user.email

user = User.new
user.email = 'gordon@svennerberg.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.name = 'Gordon Freeman'
user.language = 'en'
user.save!

puts 'CREATED REGULAR USER: ' << user.email


1.upto(100) do |i|
	ad = Ad.new
	ad.description = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eaque, impedit ipsam laborum nostrum illum nihil, id qui maiores voluptates aperiam animi quisquam, deserunt cupiditate maxime commodi placeat enim, autem quas!"
	ad.price = 5000 * i
	ad.volume = i
	ad.volume_unit = 'sack'
	ad.user = user
	ad.crop_type = crop_type
	ad.village = 'Mbola'
	ad.region = 'Uyui'
	ad.save!
end
puts 'CREATED 100 ADS by ' << user.email