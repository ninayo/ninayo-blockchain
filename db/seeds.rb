# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

AdLog.delete_all
Ad.delete_all
User.delete_all
CropType.delete_all
EventType.delete_all

1.upto(10) do |i|
	crop_type = CropType.new
	crop_type.name = 'Crop Type ' + i.to_s
	crop_type.save!
end

crop_type = CropType.new
crop_type.name = 'Maize'
crop_type.save!

puts 'CREATED 11 CROP_TYPES'

event_type = EventType.new
event_type.name = 'Show ad'
event_type.save!

event_type = EventType.new
event_type.name = 'Show contact info'
event_type.save!

puts 'CREATED 2 EVENT_TYPES'

user = User.new
user.username = 'svennerberg'
user.email = 'gabriel@svennerberg.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.role = 'admin'
user.name = 'Gabriel Svennerberg'
user.language = 'en'
user.save!

user = User.new
user.username = 'gordon'
user.email = 'gordon@svennerberg.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.name = 'Gordon Freeman'
user.language = 'en'
user.save!

1.upto(200) do |i|
	user = User.new
	email = Faker::Internet.email
	user.username = email
	user.email = email
	user.phone_number = Faker::PhoneNumber.cell_phone #=> "(186)285-7925"
	user.password = 'thug4life'
	user.password_confirmation = 'thug4life'
	user.name = Faker::Name.name
	user.language = 'en'
	user.save!
end
puts 'CREATED 500 FAKE USERS '

1.upto(1000) do |i|
	ad = Ad.new
	ad.description = Faker::Lorem.sentence(20, false, 4)
	ad.price = Faker::Number.number(5)
	ad.volume = Faker::Number.number(2)
	ad.volume_unit = 'sack'
	ad.user = User.find(rand(2..202))
	ad.crop_type = CropType.find(rand(1..10))
	ad.village = Faker::Address.city
	ad.region = Faker::Address.state
	ad.lat = Faker::Address.latitude
	ad.lng = Faker::Address.longitude
	ad.status = 'published'
	ad.published_at = Faker::Time.between(20.days.ago, Time.now, :all) #=> "2014-09-19 07:03:30 -0700"
	ad.save!
end
puts 'CREATED 1000 ADS'

1.upto(3000) do |i|
	log_entry = AdLog.new
	log_entry.user = User.find(rand(2..202))
	log_entry.ad = Ad.find(rand(1..1000))
	log_entry.event_type = EventType.first
	log_entry.save!
end

1.upto(1000) do |i|
	log_entry = AdLog.new
	log_entry.user = User.find(rand(2..202))
	log_entry.ad = Ad.find(rand(1..1000))
	log_entry.event_type = EventType.last
	log_entry.save!
end

puts 'CREATED 4000 AD_LOGS ENTRIES'