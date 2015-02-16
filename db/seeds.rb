# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = User.new
user.email = 'gabriel@svennerberg.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.role = 'admin'
user.authentication_token = '1G8_s7P-V-4MGojaKD7a'
user.first_name = 'Gabriel'
user.last_name = 'Svennerberg'
user.language = 'se'
user.save!

user = User.new
user.email = 'gordon@svennerberg.com'
user.password = 'thug4life'
user.password_confirmation = 'thug4life'
user.authentication_token = 'gZzQWqzmsQ_iu3uhiiFT'
user.first_name = 'Gordon'
user.last_name = 'Freeman'
user.language = 'se'
user.save!

puts 'CREATED REGULAR USER: ' << user.email