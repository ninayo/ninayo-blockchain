ActiveAdmin.register TextLog do
  config.per_page = 25

  index pagination_total: false do
    column :ad_id
    column :sender
    column :receiver
    column :created_at
  end

  filter :region, as: :check_boxes, collection: proc { Region.all }
  filter :created_at, as: :date_range

  remove_filter :sender
  remove_filter :receiver
  remove_filter :ad
  remove_filter :updated_at
end
