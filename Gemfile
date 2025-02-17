source 'https://rubygems.org'
ruby '2.5.1'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.21'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.1'
# gem 'compass-rails'
gem 'compass', '1.0.3'
gem 'compass-rails', '2.0.4'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'kaminari'
gem 'devise'
gem 'puma', '~> 2.9.1'
gem 'client_side_validations', github: "DavyJonesLocker/client_side_validations", branch: "4-2-stable"

gem 'heroku_rails_deflate', :group => :production

gem 'markdown-rails'

gem 'roo'


# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'faker'
gem 'mail'
gem 'annotate'

gem 'pry-rails'
gem 'omniauth-facebook'

gem 'mailboxer'

gem 'split', require: 'split/dashboard'
gem 'redis-namespace'

gem 'social-share-button'

# stuff for price page
gem 'chartkick'
gem 'hightop'
gem 'groupdate'

gem 'twilio-ruby'

#gem 'delayed_job', github: "collectiveidea/delayed_job", branch: "master"
gem 'delayed_job_active_record'

gem 'activeadmin'
# gem 'activeadmin-axlsx'
gem 'responsive_active_admin'

# gem 'zip-zip'

#gem 'skylight'

group :development do
  gem 'heroku'
  gem 'meta_request'
  gem 'bullet'
  gem 'letter_opener'
  gem 'rdoc'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Load development env files
  gem 'dotenv-rails'
end

group :production do
	gem 'rails_12factor'
  gem 'newrelic_rpm'
end
