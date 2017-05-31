ActiveAdmin.register TextLog do
  config.per_page = 25

  index pagination_total: false do
    column :id
    column :ad_id
    column :sender
    column :receiver
    column :created_at
  end

  filter :region, as: :check_boxes, collection: proc { Region.all }

  remove_filter :sender
  remove_filter :receiver
  remove_filter :ad
  remove_filter :updated_at
end
