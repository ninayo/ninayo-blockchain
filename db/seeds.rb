['all', Rails.env].each do |seed|
  seed_file = "#{Rails.root}/db/seeds/#{seed}.rb"
  if File.exists?(seed_file)
    puts "*** Loading #{seed} seed data"
    require seed_file
  end
endAdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')