ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  config.per_page = 25

  index pagination_total: false do
    column :id
    column :name
    column :phone_number
    column :region
    column :village
    column :gender
    column :sign_in_count
    column :last_sign_in_at
  end

  filter :region, as: :select, collection: proc { Region.all }

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
