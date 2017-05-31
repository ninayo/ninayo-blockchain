ActiveAdmin.register User do
  config.per_page = 25

  index pagination_total: false do
    column :id
    column :name
    column :phone_number
    column :ads_posted do |user|
      user.ads.count
    end
    column :contacts_made do |user|
      user.calls_made.count + user.texts_sent.count
    end
    column :contacts_received do |user|
      user.calls_received.count + user.texts_received.count
    end
    column :region
    column :village
    column :gender
    column :sign_in_count
    column :last_sign_in_at
  end

  filter :name_contains
  filter :region, as: :select, collection: proc { Region.all }
  filter :created_at, as: :date_range

  remove_filter :encrypted_password
  remove_filter :id
  remove_filter :reset_password_token
  remove_filter :reset_password_sent_at
  remove_filter :remember_created_at
  remove_filter :role
  remove_filter :language
  remove_filter :uid
  remove_filter :seller_rating
  remove_filter :buyer_rating
  remove_filter :fb_bot_id
  remove_filter :whatsapp_id
  remove_filter :birthday
  remove_filter :age_range
end
