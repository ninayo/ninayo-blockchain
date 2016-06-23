# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

AdLog.delete_all
Rating.delete_all
FavoriteAd.delete_all
Ad.delete_all
User.delete_all
CropType.delete_all
EventType.delete_all
Region.delete_all

CropType.create!(:name => "Maize", :name_sw => "Mahindi", :sort_order => 1)
CropType.create!(:name => "Potatoes", :name_sw => "Viazi", :sort_order => 2)
CropType.create!(:name => "Rice", :name_sw => "Mchele", :sort_order => 3)
CropType.create!(:name => "Casava", :name_sw => "Muhogo", :sort_order => 4)
CropType.create!(:name => "Beans", :name_sw => "Maharage", :sort_order => 5)
CropType.create!(:name => "Avocadoes", :name_sw => "Maparachichi", :sort_order => 6)
CropType.create!(:name => "Mangoes", :name_sw => "Maembe", :sort_order => 7)
CropType.create!(:name => "Tomatoes", :name_sw => "Nyanya", :sort_order => 8)
CropType.create!(:name => "Bananas", :name_sw => "Ndizi", :sort_order => 9)
CropType.create!(:name => "Other", :name_sw => "Nyingine", :sort_order => 999)
CropType.create!(:name => "Unmilled Rice", :name_sw => "Mpunga", :sort_order => 10)
CropType.create!(:name => "Coffee", :name_sw => "Kahawa", :sort_order => 11)
CropType.create!(:name => "Onions", :name_sw => "Vitunguu", :sort_order => 12)


puts 'CREATED 10 CROP_TYPES'

Region.create!(:name => 'Arusha')
Region.create!(:name => 'Dar es Salaam')
Region.create!(:name => 'Dodoma')
Region.create!(:name => 'Geita')
Region.create!(:name => 'Iringa')
Region.create!(:name => 'Kagera')
Region.create!(:name => 'Katavi')
Region.create!(:name => 'Kigoma')
Region.create!(:name => 'Kilimanjaro')
Region.create!(:name => 'Lindi')
Region.create!(:name => 'Manyara')
Region.create!(:name => 'Mara')
Region.create!(:name => 'Mbeya')
Region.create!(:name => 'Morogoro')
Region.create!(:name => 'Mtwara')
Region.create!(:name => 'Mwanza')
Region.create!(:name => 'Njombe')
Region.create!(:name => 'Pemba North')
Region.create!(:name => 'Pemba South')
Region.create!(:name => 'Pwani')
Region.create!(:name => 'Rukwa')
Region.create!(:name => 'Ruvuma')
Region.create!(:name => 'Shinyanga')
Region.create!(:name => 'Simiyu')
Region.create!(:name => 'Singida')
Region.create!(:name => 'Tabora')
Region.create!(:name => 'Tanga')
Region.create!(:name => 'Zanzibar North')
Region.create!(:name => 'Zanzibar South and Central')
Region.create!(:name => 'Zanzibar West')

puts 'CREATED 30 REGIONS'

EventType.create!(:name => 'Show ad')
EventType.create!(:name => 'Show contact info')

puts 'CREATED 2 EVENT_TYPES'

user = User.new
user.email = 'gabriel@svennerberg.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.role = 'admin'
user.name = 'Gabriel Svennerberg'
user.language = 'en'
user.agreement = true
user.save!

user = User.new
user.email = 'staffan@ninayo.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.role = 'admin'
user.name = 'Staffan Kerker'
user.language = 'en'
user.agreement = true
user.save!

user = User.new
user.email = 'gordon@svennerberg.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.name = 'Gordon Freeman'
user.language = 'en'
user.agreement = true
user.save!

1.upto(200) do |i|
	user = User.new
	user.email = Faker::Internet.email
	user.phone_number = Faker::PhoneNumber.cell_phone #=> "(186)285-7925"
	user.password = 'thug4life'
	user.password_confirmation = 'thug4life'
	user.name = Faker::Name.name
	user.language = 'en'
	user.agreement = true
	user.save!
end
puts 'CREATED 200 FAKE USERS '

1.upto(1000) do |i|
	ad = Ad.new
	ad.ad_type = rand(0..1)
	ad.description = Faker::Lorem.sentence(20, false, 4)
	ad.price = Faker::Number.number(5)
	ad.volume = Faker::Number.number(2)
	ad.volume_unit = 'sack'
	ad.user = User.find(rand(2..202))
	ad.crop_type = CropType.find(rand(1..10))
	if ad.crop_type.id == 10
		ad.other_crop_type = Faker::Lorem.word
	end
	ad.village = Faker::Address.city
	ad.region = Region.find(rand(1..30))
	# ad.lat = Faker::Address.latitude
	# ad.lng = Faker::Address.longitude
	# nw -1.112499, 31.420803
	# ne -4.634119, 39.012356
	# sw -8.486156, 31.179104
	# se -10.404279, 40.143948
	ad.lat = rand(-10.4..-1.1)
	ad.lng = rand(31.2..40.1)
	ad.status = 'published'
	ad.published_at = Faker::Time.between(30.days.ago, Time.now, :all) #=> "2014-09-19 07:03:30 -0700"
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

1.upto(1000) do |i|
	User.find(rand(2..202)).favorites << Ad.find(rand(1..1000))
end
puts 'CREATED 1000 FAVORITES'


1.upto(1000) do |i|
	Rating.create!(:user => User.find(rand(2..202)), :rater_id => User.find(rand(2..202)).id, :ad => Ad.find(rand(1..1000)), :score=> rand(1..5), :role => "buyer")
end
puts 'CREATED 1000 RATINGS FOR BUYERS'

1.upto(1000) do |i|
	Rating.create!(:user => User.find(rand(2..202)), :rater_id => User.find(rand(2..202)).id, :ad => Ad.find(rand(1..1000)), :score=> rand(1..5), :role => "seller")
end
puts 'CREATED 1000 RATINGS FOR SELLERS'