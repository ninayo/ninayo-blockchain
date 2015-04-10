CropType.create!(:name => "Maize", :name_sw => "Mahindi")
CropType.create!(:name => "Potatoes", :name_sw => "Viazi")
CropType.create!(:name => "Rice", :name_sw => "Mchele")
CropType.create!(:name => "Casava", :name_sw => "Muhogo")
CropType.create!(:name => "Beans", :name_sw => "Maharage")
CropType.create!(:name => "Avocadoes", :name_sw => "Maparachichi")
CropType.create!(:name => "Mangoes", :name_sw => "Maembe")
CropType.create!(:name => "Tomatoes", :name_sw => "Nyanya")
CropType.create!(:name => "Bananas", :name_sw => "Ndizi")
CropType.create!(:name => "Other", :name_sw => "Nyingine")

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
user.save!

user = User.new
user.email = 'staffan@ninayo.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.role = 'admin'
user.name = 'Staffan Kerker'
user.language = 'en'
user.save!

user = User.new
user.email = 'gordon@svennerberg.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.name = 'Gordon Freeman'
user.language = 'en'
user.save!