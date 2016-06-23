##TO BUILD:

###USSD API
- [ ] - postAd
- [x] - getAdsForUser
- [ ] - archiveAd
- [x] - getUnits
- [x] - getCropTypes
- [x] - getRegions

###ADMIN PANEL
- [ ] - https://github.com/activeadmin/activeadmin
- [ ] - metabase (not ready for primetime on heroku yet)

###MESSAGES
- [ ] - https://github.com/mailboxer/mailboxer

###CROP TYPES
- [x] - Coffee (Kawaha)
- [x] - Onions (Vitunguu)

###MAP IMPROVEMENTS
- [ ] - Marker culling (don't draw markers older than 30 days)

###LOGIN/LANDING PAGE
- [ ] - User landing prompting login/signup
- [ ] - Facebook oauth login

###POST IMPROVEMENTS
- [ ] - "Similar ads" carousel somewhere on ad listing
- [ ] - User alert messages

---------------------

##TO FIX:

- [x] - Broken images on map (check gh for markerclusterer, new image URI)
- [x] - Adblocker problem (caused by #ad-wrapper divs)

###SECURITY ISSUES
- [x] - SQLi on ad.rb:60
- [x] - SQLi on ad.rb:61
- [ ] - SQLi on ad_log.rb:11
- [ ] - XSS in rails-html-sanitizer 1.0.2, upgrade gem to 1.0.3+
- [ ] - DOS in Rails 4.2.5
