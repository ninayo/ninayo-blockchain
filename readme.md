# Development Guide:

## Prerequisites
- Ruby 2.2.3 (recommended to use `rvm install`)
- Postgres (use `brew install postgres`)
- Bundler (see https://bundler.io/)
- openssl (`brew install openssl`)

## Setup
- `bundle install` (and fix any conflicts/errors)
- Create postgres user (`createuser --superuser svennerberg`)
- Create db by running `rake db:create`
- Migrate db changes from schema by running `rake db:migrate`

## Run
- `rails s`

## Notes
- Remember to specify `RAILS_ENV=development` for targetting specific environments (development, test, production)

# TO BUILD:

### USSD API
- [x] - postAd
- [x] - getAdsForUser
- [x] - archiveAd
- [x] - getUnits
- [x] - getCropTypes
- [x] - getRegions

### ADMIN PANEL
- [ ] - https://github.com/activeadmin/activeadmin
- [x] - metabase

### MESSAGES
- [x] - https://github.com/mailboxer/mailboxer

### CROP TYPES
- [x] - Coffee (Kawaha)
- [x] - Onions (Vitunguu)

### MAP IMPROVEMENTS
- [x] - Marker culling (don't draw markers older than 30 days)

### LOGIN/LANDING PAGE
- [x] - User landing prompting login/signup
- [x] - Facebook oauth login

### POST IMPROVEMENTS
- [ ] - "Similar ads" carousel somewhere on ad listing
- [ ] - User alert messages

---------------------

## TO FIX:

- [x] - Broken images on map (check gh for markerclusterer, new image URI)
- [x] - Adblocker problem (caused by #ad-wrapper divs)

### SECURITY ISSUES
- [x] - SQLi on ad.rb:60
- [x] - SQLi on ad.rb:61
- [x] - SQLi on ad_log.rb:11
- [x] - XSS in rails-html-sanitizer 1.0.2, upgrade gem to 1.0.3+
- [ ] - DOS in Rails 4.2.5
